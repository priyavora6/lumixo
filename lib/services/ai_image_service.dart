// lib/services/ai_image_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AiImageService {
  // API Keys will be loaded from Firestore
  String? _openAiKey;
  String? _geminiKey;
  String? _replicateKey;
  String? _huggingFaceKey;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _keysLoaded = false;

  // Track stats
  int successCount = 0;
  int failCount = 0;
  String lastUsedApi = '';

  // ═══════════════════════════════════════════════════
  // 🔑 LOAD API KEYS FROM FIRESTORE
  // ═══════════════════════════════════════════════════
  Future<void> _loadApiKeys() async {
    try {
      // Keys are stored in a document named 'api_keys' inside the 'app_config' collection
      final doc = await _firestore.collection('app_config').doc('api_keys').get();
      if (doc.exists) {
        final data = doc.data()!;
        _openAiKey = data['openai_key'];
        _geminiKey = data['gemini_key'];
        _replicateKey = data['replicate_key'];
        _huggingFaceKey = data['huggingface_key'];
      }
    } finally {
      _keysLoaded = true; // Mark as loaded to prevent retries, even if it fails
    }
  }


  // ═══════════════════════════════════════════════════
  // 🎯 MAIN METHOD: Try all APIs, upload to Firebase
  // ═══════════════════════════════════════════════════
  Future<String> generateAndUpload({
    required String prompt,
    required String folder,
    required String fileName,
  }) async {
    if (!_keysLoaded) {
      await _loadApiKeys();
    }

    final cleanPrompt = _cleanPrompt(prompt);

    // Try each API in order of preference
    final apis = [
      () => _tryPollinations(cleanPrompt),
      () => _tryHuggingFace(cleanPrompt),
      () => _tryOpenAI(cleanPrompt),
      () => _tryReplicate(cleanPrompt),
      () => _tryGemini(cleanPrompt),
    ];

    for (int i = 0; i < apis.length; i++) {
      try {
        final imageBytes = await apis[i]();
        if (imageBytes != null && imageBytes.length > 5000) {
          // Upload to Firebase Storage
          final url = await _uploadToFirebase(
            imageBytes: imageBytes,
            folder: folder,
            fileName: fileName,
          );
          if (url != null) {
            successCount++;
            return url;
          }
        }
      } catch (e) {
        // Try next API
        continue;
      }
    }

    // All APIs failed - use fallback
    failCount++;
    return _fallbackUrl(cleanPrompt);
  }

  // ═══════════════════════════════════════════════════
  // 1️⃣ POLLINATIONS (FREE - No API Key!)
  // ═══════════════════════════════════════════════════
  Future<Uint8List?> _tryPollinations(String prompt) async {
    lastUsedApi = 'Pollinations';
    final seed = prompt.hashCode.abs() % 999999;
    final encoded = Uri.encodeComponent(prompt);

    // Try multiple Pollinations endpoints
    final urls = [
      'https://image.pollinations.ai/prompt/$encoded?width=512&height=512&seed=$seed&nologo=true',
      'https://image.pollinations.ai/prompt/$encoded?width=400&height=400&seed=$seed&nologo=true&model=flux-realism',
      'https://image.pollinations.ai/prompt/$encoded?width=400&height=400&seed=$seed',
    ];

    for (final url in urls) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200 && response.bodyBytes.length > 5000) {
          final contentType = response.headers['content-type'] ?? '';
          if (contentType.contains('image') ||
              response.bodyBytes.length > 10000) {
            return response.bodyBytes;
          }
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  // ═══════════════════════════════════════════════════
  // 2️⃣ HUGGING FACE (FREE tier available)
  // ═══════════════════════════════════════════════════
  Future<Uint8List?> _tryHuggingFace(String prompt) async {
    if (_huggingFaceKey == null || _huggingFaceKey!.isEmpty) return null;

    lastUsedApi = 'HuggingFace';

    // Try multiple models
    final models = [
      'stabilityai/stable-diffusion-xl-base-1.0',
      'runwayml/stable-diffusion-v1-5',
      'CompVis/stable-diffusion-v1-4',
    ];

    for (final model in models) {
      try {
        final response = await http.post(
          Uri.parse('https://api-inference.huggingface.co/models/$model'),
          headers: {
            'Authorization': 'Bearer $_huggingFaceKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'inputs': '$prompt, high quality, detailed, professional',
            'parameters': {
              'width': 512,
              'height': 512,
            },
          }),
        ).timeout(const Duration(seconds: 45));

        if (response.statusCode == 200 && response.bodyBytes.length > 5000) {
          return response.bodyBytes;
        }

        // Model loading - wait and retry
        if (response.statusCode == 503) {
          await Future.delayed(const Duration(seconds: 10));
          final retry = await http.post(
            Uri.parse(
                'https://api-inference.huggingface.co/models/$model'),
            headers: {
              'Authorization': 'Bearer $_huggingFaceKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'inputs': '$prompt, high quality, detailed',
            }),
          ).timeout(const Duration(seconds: 45));

          if (retry.statusCode == 200 && retry.bodyBytes.length > 5000) {
            return retry.bodyBytes;
          }
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  // ═══════════════════════════════════════════════════
  // 3️⃣ OPENAI DALL-E (Paid - Best Quality)
  // ═══════════════════════════════════════════════════
  Future<Uint8List?> _tryOpenAI(String prompt) async {
    if (_openAiKey == null || _openAiKey!.isEmpty) return null;

    lastUsedApi = 'OpenAI DALL-E';

    try {
      // Step 1: Generate image URL from DALL-E
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Authorization': 'Bearer $_openAiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'dall-e-3',
          'prompt': prompt,
          'n': 1,
          'size': '1024x1024',
          'quality': 'standard',
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['data'][0]['url'] as String;

        // Step 2: Download the image
        final imgResponse = await http
            .get(Uri.parse(imageUrl))
            .timeout(const Duration(seconds: 30));

        if (imgResponse.statusCode == 200) {
          return imgResponse.bodyBytes;
        }
      }
    } catch (_) {}
    return null;
  }

  // ═══════════════════════════════════════════════════
  // 4️⃣ REPLICATE (Stable Diffusion & more)
  // ═══════════════════════════════════════════════════
  Future<Uint8List?> _tryReplicate(String prompt) async {
    if (_replicateKey == null || _replicateKey!.isEmpty) return null;

    lastUsedApi = 'Replicate';

    try {
      // Step 1: Create prediction
      final createResponse = await http.post(
        Uri.parse('https://api.replicate.com/v1/predictions'),
        headers: {
          'Authorization': 'Token $_replicateKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'version':
          'ac732df83cea7fff18b8472768c88ad041fa750ff7682a21affe81863cbe77e4',
          'input': {
            'prompt': '$prompt, high quality, professional, 4K',
            'width': 512,
            'height': 512,
            'num_outputs': 1,
          },
        }),
      ).timeout(const Duration(seconds: 30));

      if (createResponse.statusCode == 201) {
        final prediction = jsonDecode(createResponse.body);
        final predictionId = prediction['id'];

        // Step 2: Poll for result
        for (int i = 0; i < 30; i++) {
          await Future.delayed(const Duration(seconds: 2));

          final statusResponse = await http.get(
            Uri.parse(
                'https://api.replicate.com/v1/predictions/$predictionId'),
            headers: {
              'Authorization': 'Token $_replicateKey',
            },
          );

          if (statusResponse.statusCode == 200) {
            final result = jsonDecode(statusResponse.body);

            if (result['status'] == 'succeeded') {
              final outputUrl = result['output'][0] as String;

              // Download image
              final imgResponse = await http
                  .get(Uri.parse(outputUrl))
                  .timeout(const Duration(seconds: 30));

              if (imgResponse.statusCode == 200) {
                return imgResponse.bodyBytes;
              }
            } else if (result['status'] == 'failed') {
              break;
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  // ═══════════════════════════════════════════════════
  // 5️⃣ GOOGLE GEMINI (Image Generation)
  // ═══════════════════════════════════════════════════
  Future<Uint8List?> _tryGemini(String prompt) async {
    if (_geminiKey == null || _geminiKey!.isEmpty) return null;

    lastUsedApi = 'Gemini';

    try {
      // Gemini Imagen API
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-generate-002:predict?key=$_geminiKey',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'instances': [
            {'prompt': prompt}
          ],
          'parameters': {
            'sampleCount': 1,
            'aspectRatio': '1:1',
          },
        }),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final base64Image =
        data['predictions'][0]['bytesBase64Encoded'] as String;
        return base64Decode(base64Image);
      }
    } catch (_) {}

    // Try Gemini 2.0 Flash (experimental image gen)
    try {
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$_geminiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'Generate an image: $prompt'}
              ]
            }
          ],
          'generationConfig': {
            'responseModalities': ['TEXT', 'IMAGE'],
          },
        }),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parts = data['candidates'][0]['content']['parts'] as List;
        for (var part in parts) {
          if (part.containsKey('inlineData')) {
            final base64Str = part['inlineData']['data'] as String;
            return base64Decode(base64Str);
          }
        }
      }
    } catch (_) {}

    return null;
  }

  // ═══════════════════════════════════════════════════
  // 📤 UPLOAD TO FIREBASE STORAGE
  // ═══════════════════════════════════════════════════
  Future<String?> _uploadToFirebase({
    required Uint8List imageBytes,
    required String folder,
    required String fileName,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child('lumixo_images')
          .child(folder)
          .child('$fileName.jpg');

      await ref.putData(
        imageBytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'generated_by': lastUsedApi,
            'generated_at': DateTime.now().toIso8601String(),
          },
        ),
      );

      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════
  // 🧹 HELPERS
  // ═══════════════════════════════════════════════════
  String _cleanPrompt(String prompt) {
    return prompt
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s,.-]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _fallbackUrl(String prompt) {
    final seed = prompt.hashCode.abs() % 999999;
    return 'https://picsum.photos/seed/$seed/400/400';
  }
}