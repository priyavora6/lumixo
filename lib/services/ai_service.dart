import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';
import 'firestore_service.dart';
import '../utils/constants.dart';

class AIService {
  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService();

  // Main transform function
  Future<String?> transformPhoto({
    required File imageFile,
    required String prompt,
    required String userId,
  }) async {
    try {
      // Step 1 — Upload photo to Firebase Storage
      final String? imageUrl = await _storageService.uploadPhoto(
        imageFile,
        userId,
      );
      if (imageUrl == null) return null;

      // Step 2 — Get API key from Firestore
      final String apiKey = await _firestoreService.getApiKey();
      if (apiKey.isEmpty) return null;

      // Step 3 — Send to Replicate
      final String? predictionId = await _startPrediction(
        imageUrl: imageUrl,
        prompt: prompt,
        apiKey: apiKey,
      );
      if (predictionId == null) return null;

      // Step 4 — Poll for result
      return await _pollForResult(predictionId, apiKey);
    } catch (e) {
      print('Transform Photo Error: $e');
      return null;
    }
  }

  // Start prediction
  Future<String?> _startPrediction({
    required String imageUrl,
    required String prompt,
    required String apiKey,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.replicateBaseUrl),
        headers: {
          'Authorization': 'Token $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'version': AppConstants.replicateModel,
          'input': {
            'image': imageUrl,
            'prompt': prompt,
            'strength': 0.7,
            'guidance_scale': 7.5,
            'num_inference_steps': 50,
          },
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'];
      }
      return null;
    } catch (e) {
      print('Start Prediction Error: $e');
      return null;
    }
  }

  // Poll for result
  Future<String?> _pollForResult(
      String predictionId,
      String apiKey,
      ) async {
    for (int i = 0; i < 40; i++) {
      await Future.delayed(const Duration(seconds: 3));

      try {
        final response = await http.get(
          Uri.parse(
            '${AppConstants.replicateBaseUrl}/$predictionId',
          ),
          headers: {'Authorization': 'Token $apiKey'},
        );

        final data = jsonDecode(response.body);
        final String status = data['status'];

        if (status == 'succeeded') {
          final List outputs = data['output'];
          return outputs.first;
        } else if (status == 'failed') {
          print('Prediction failed: ${data['error']}');
          return null;
        }
        // Still processing — continue polling
      } catch (e) {
        print('Poll Error: $e');
      }
    }
    return null; // Timeout
  }
}