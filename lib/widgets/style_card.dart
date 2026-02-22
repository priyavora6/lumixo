import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/style_model.dart';
import '../utils/colors.dart';

class StyleCard extends StatelessWidget {
  final StyleModel style;
  final VoidCallback onTap;
  final bool isPremiumUser;

  const StyleCard({
    super.key,
    required this.style,
    required this.onTap,
    required this.isPremiumUser,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLocked = style.isPremium && !isPremiumUser;

    return GestureDetector(
      onTap: isLocked
          ? () => _showPremiumDialog(context)
          : onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: style.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: style.imageUrl,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        color: AppColors.primary
                            .withOpacity(0.1),
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    // Lock overlay
                    if (isLocked)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black
                              .withOpacity(0.4),
                          child: const Center(
                            child: Icon(
                              Icons.lock_rounded,
                              color: AppColors.premiumGold,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    // Premium badge
                    if (style.isPremium)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            gradient:
                            AppColors.premiumGradient,
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '👑 PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Name
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                style.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('👑 Premium Style'),
        content: const Text(
          'This style is for Premium users only. Upgrade to unlock all styles!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/premium');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text(
              'Upgrade',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}