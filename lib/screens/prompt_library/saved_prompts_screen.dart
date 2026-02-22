import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/prompt_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/prompt_card.dart';
import '../../utils/colors.dart';

class SavedPromptsScreen extends StatelessWidget {
  const SavedPromptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isPremium =
        context.watch<UserProvider>().isPremium;
    final userId =
        context.watch<UserProvider>().user?.uid ?? '';

    return Consumer<PromptProvider>(
      builder: (context, provider, child) {
        final savedPrompts = provider.allPrompts
            .where((p) => provider.isPromptSaved(p.id))
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              '🔖 Saved Prompts (${savedPrompts.length})',
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(
              color: AppColors.textDark,
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
            child: savedPrompts.isEmpty
                ? _buildEmpty(context)
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savedPrompts.length,
              itemBuilder: (context, index) {
                final prompt = savedPrompts[index];
                return PromptCard(
                  prompt: prompt,
                  isSaved: true,
                  isPremiumUser: isPremium,
                  onSave: userId.isNotEmpty
                      ? () => provider
                      .toggleSavePrompt(
                      prompt, userId)
                      : null,
                  onTap: () =>
                      Navigator.pushNamed(
                        context,
                        '/prompt-detail',
                        arguments: prompt,
                      ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔖',
              style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'No saved prompts yet!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the bookmark icon on any\nprompt to save it here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMedium,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:
                    AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                'Browse Prompts ✨',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
