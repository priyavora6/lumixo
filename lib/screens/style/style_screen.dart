import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/style_model.dart';
import '../../widgets/custom_button.dart';
import '../../utils/colors.dart';
import '../../routes/app_routes.dart';

class StyleScreen extends StatelessWidget {
  final StyleModel style;
  const StyleScreen({super.key, required this.style});

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
                    Text(
                      style.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Preview image
                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(24),
                        child: style.imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl:
                          style.imageUrl,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          height: 300,
                          color: AppColors.primary
                              .withOpacity(0.1),
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 60,
                              color:
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Style name
                      Text(
                        style.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Info
                      Container(
                        padding:
                        const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(
                              16),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons
                                  .auto_awesome_rounded,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'AI will transform your photo into this style automatically',
                                style: TextStyle(
                                  color:
                                  AppColors.textMedium,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      CustomButton(
                        text: '📸 Use This Style',
                        onPressed: () =>
                            Navigator.pushNamed(
                              context,
                              AppRoutes.upload,
                              arguments: style,
                            ),
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
}
