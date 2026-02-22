import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/style_model.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_button.dart';
import '../../utils/colors.dart';
import '../../routes/app_routes.dart';

class UploadScreen extends StatefulWidget {
  final StyleModel? style;
  const UploadScreen({super.key, this.style});

  @override
  State<UploadScreen> createState() =>
      _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final FirestoreService _firestoreService =
  FirestoreService();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1080,
    );
    if (file != null) {
      setState(() => _selectedImage = File(file.path));
    }
  }

  Future<void> _transform() async {
    if (_selectedImage == null) return;

    final user = context.read<UserProvider>().user;
    if (user == null) return;

    // Check limit
    final result = await _firestoreService
        .checkEditLimit(user.uid);

    if (!mounted) return;

    if (!result['canEdit']) {
      _showLimitDialog(result);
      return;
    }

    // Go to processing
    Navigator.pushNamed(
      context,
      AppRoutes.processing,
      arguments: {
        'imagePath': _selectedImage!.path,
        'prompt': widget.style?.prompt ?? '',
        'styleName': widget.style?.name ?? 'Custom',
        'category': 'General',
      },
    );
  }

  void _showLimitDialog(Map result) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '⚡ Daily Limit Reached!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have used all 3 free edits today.',
              style: TextStyle(color: AppColors.textMedium),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: '👑 Go Premium — Unlimited Edits',
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                    context, AppRoutes.premium);
              },
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: '🪙 Use Coins (3 coins)',
              isOutlined: true,
              onPressed: () {
                Navigator.pop(context);
                _useCoinsAndTransform();
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _useCoinsAndTransform() async {
    final user = context.read<UserProvider>().user;
    if (user == null || user.coins < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough coins!'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    await _firestoreService.useCoinsForEdit(user.uid);
    await context.read<UserProvider>().refreshUser();

    if (!mounted) return;

    Navigator.pushNamed(
      context,
      AppRoutes.processing,
      arguments: {
        'imagePath': _selectedImage!.path,
        'prompt': widget.style?.prompt ?? '',
        'styleName': widget.style?.name ?? 'Custom',
        'category': 'General',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                          Navigator.pop(context),
                    ),
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upload Photo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (widget.style != null)
                          Text(
                            'Style: ${widget.style!.name}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Upload area
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              _showPickerOptions(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(0.7),
                              borderRadius:
                              BorderRadius.circular(
                                  24),
                              border: Border.all(
                                color: AppColors.primary
                                    .withOpacity(0.3),
                                width: 2,
                                style:
                                BorderStyle.solid,
                              ),
                            ),
                            child: _selectedImage != null
                                ? ClipRRect(
                              borderRadius:
                              BorderRadius
                                  .circular(22),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width:
                                double.infinity,
                              ),
                            )
                                : Column(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration:
                                  BoxDecoration(
                                    color: AppColors
                                        .primary
                                        .withOpacity(
                                        0.1),
                                    shape: BoxShape
                                        .circle,
                                  ),
                                  child: const Icon(
                                    Icons
                                        .add_photo_alternate_outlined,
                                    color: AppColors
                                        .primary,
                                    size: 36,
                                  ),
                                ),
                                const SizedBox(
                                    height: 16),
                                const Text(
                                  'Tap to upload photo',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                    FontWeight
                                        .w600,
                                    color: AppColors
                                        .textDark,
                                  ),
                                ),
                                const SizedBox(
                                    height: 8),
                                const Text(
                                  'Gallery or Camera',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors
                                        .textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Buttons
                      if (_selectedImage != null)
                        CustomButton(
                          text: '✨ Transform Now!',
                          onPressed: _transform,
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: '📷 Camera',
                                onPressed: () => _pickImage(
                                    ImageSource.camera),
                                isOutlined: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomButton(
                                text: '🖼️ Gallery',
                                onPressed: () => _pickImage(
                                    ImageSource.gallery),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primary),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
