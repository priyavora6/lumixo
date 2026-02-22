import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/prompt_model.dart';
import '../utils/colors.dart';
import '../routes/app_routes.dart';

class PromptCard extends StatelessWidget {
  final PromptModel prompt;
  final bool isSaved;
  final bool isPremiumUser;

  // ✅ onTap — fixes: named parameter 'onTap' required
  final VoidCallback? onTap;

  // ✅ onSave — fixes: named parameter 'onSave' not defined
  final VoidCallback? onSave;

  const PromptCard({
    super.key,
    required this.prompt,

    // ✅ title not needed — removed (was causing error)
    // title is already inside PromptModel

    this.isSaved = false,
    this.isPremiumUser = false,
    this.onTap,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLocked =
        prompt.isPremium && !isPremiumUser;

    return GestureDetector(
      onTap: onTap ??
              () {
            // Default tap — go to prompt detail
            Navigator.pushNamed(
              context,
              AppRoutes.promptDetail,
              arguments: prompt,
            );
          },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // ── Top Row ────────────────────────
              Row(
                children: [
                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary
                          .withOpacity(0.1),
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                    child: Text(
                      prompt.category,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Trending badge
                  if (prompt.isTrending)
                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange
                            .withOpacity(0.1),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '🔥 Trending',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Premium badge
                  if (prompt.isPremium)
                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
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
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const SizedBox(width: 8),

                  // Save/Bookmark button
                  GestureDetector(
                    onTap: onSave,
                    child: Icon(
                      isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: isSaved
                          ? AppColors.primary
                          : AppColors.textLight,
                      size: 22,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Title ──────────────────────────
              Text(
                prompt.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 6),

              // ── Prompt Preview ─────────────────
              Text(
                isLocked
                    ? '🔒 Unlock with Premium to see this prompt'
                    : prompt.prompt,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: isLocked
                      ? AppColors.textLight
                      : AppColors.textMedium,
                  height: 1.5,
                  fontStyle: isLocked
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),

              const SizedBox(height: 10),

              // ── Bottom Row ─────────────────────
              Row(
                children: [
                  // Tags
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: prompt.tags
                            .take(3)
                            .map(
                              (tag) => Container(
                            margin:
                            const EdgeInsets
                                .only(right: 6),
                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey
                                  .withOpacity(0.1),
                              borderRadius:
                              BorderRadius.circular(
                                  10),
                            ),
                            child: Text(
                              '#$tag',
                              style: const TextStyle(
                                fontSize: 11,
                                color:
                                AppColors.textLight,
                              ),
                            ),
                          ),
                        )
                            .toList(),
                      ),
                    ),
                  ),

                  // Copy button
                  if (!isLocked)
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(
                            text: prompt.prompt));
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: const Text(
                                '✅ Copied to clipboard!'),
                            backgroundColor:
                            AppColors.successColor,
                            behavior:
                            SnackBarBehavior.floating,
                            duration: const Duration(
                                seconds: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                  12),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary
                              .withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.copy_rounded,
                              size: 13,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Copy',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}