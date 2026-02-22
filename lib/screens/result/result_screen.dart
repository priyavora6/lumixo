import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/before_after_slider.dart';
import '../../widgets/custom_button.dart';
import '../../utils/colors.dart';
import '../../routes/app_routes.dart';

class ResultScreen extends StatefulWidget {
  final String resultUrl;
  final String originalPath;
  final String styleName;
  final String category;

  const ResultScreen({
    super.key,
    required this.resultUrl,
    required this.originalPath,
    required this.styleName,
    required this.category,
  });

  @override
  State<ResultScreen> createState() =>
      _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final FirestoreService _firestoreService =
  FirestoreService();
  bool _isSaving = false;
  bool _showSlider = false;

  @override
  void initState() {
    super.initState();
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    await _firestoreService.saveEditHistory(
      userId: user.uid,
      originalImage: widget.originalPath,
      resultImage: widget.resultUrl,
      styleName: widget.styleName,
      category: widget.category,
      isPremium: user.isPremium,
    );
  }

  Future<void> _downloadImage() async {
    setState(() => _isSaving = true);

    try {
      final response =
      await http.get(Uri.parse(widget.resultUrl));
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
          '${dir.path}/lumixo_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(response.bodyBytes);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Photo saved successfully!'),
          backgroundColor: AppColors.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save photo'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }

    setState(() => _isSaving = false);
  }

  Future<void> _shareImage() async {
    try {
      final response =
      await http.get(Uri.parse(widget.resultUrl));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/share_lumixo.jpg');
      await file.writeAsBytes(response.bodyBytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Transformed with Lumixo ✨',
      );
    } catch (e) {
      print('Share error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremium =
        context.watch<UserProvider>().isPremium;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: AppColors.textDark,
                      ),
                      onPressed: () =>
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.home,
                                (route) => false,
                          ),
                    ),
                    const Text(
                      'Your Result ✨',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Spacer(),
                    // Toggle slider
                    TextButton.icon(
                      onPressed: () => setState(
                              () => _showSlider = !_showSlider),
                      icon: const Icon(
                          Icons.compare_rounded,
                          size: 18),
                      label: Text(
                        _showSlider
                            ? 'Hide'
                            : 'Compare',
                        style: const TextStyle(
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Image
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20),
                  child: _showSlider
                      ? BeforeAfterSlider(
                    beforeImage:
                    widget.originalPath,
                    afterImage: widget.resultUrl,
                  )
                      : ClipRRect(
                    borderRadius:
                    BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl:
                          widget.resultUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                        // Watermark for free
                        if (!isPremium)
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration:
                              BoxDecoration(
                                color: Colors.black
                                    .withOpacity(
                                    0.5),
                                borderRadius:
                                BorderRadius
                                    .circular(
                                    20),
                              ),
                              child: const Text(
                                'Lumixo ✨',
                                style: TextStyle(
                                  color:
                                  Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Style name chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                  AppColors.primary.withOpacity(0.1),
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.category} • ${widget.styleName}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: '📥 Download',
                            onPressed: _downloadImage,
                            isLoading: _isSaving,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: '📤 Share',
                            isOutlined: true,
                            onPressed: _shareImage,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: '🔄 Try Another Style',
                      isOutlined: true,
                      onPressed: () => Navigator.pushNamed(
                          context, AppRoutes.home),
                    ),
                    if (!isPremium) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.premium),
                        child: Container(
                          padding:
                          const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient:
                            AppColors.premiumGradient,
                            borderRadius:
                            BorderRadius.circular(
                                16),
                          ),
                          child: const Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Text('👑',
                                  style: TextStyle(
                                      fontSize: 18)),
                              SizedBox(width: 8),
                              Text(
                                'Remove Watermark — Go Premium',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                  FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}