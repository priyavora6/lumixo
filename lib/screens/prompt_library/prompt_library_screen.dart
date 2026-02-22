import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/prompt_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/prompt_card.dart';
import '../../utils/colors.dart';

class PromptLibraryScreen extends StatefulWidget {
  const PromptLibraryScreen({super.key});

  @override
  State<PromptLibraryScreen> createState() =>
      _PromptLibraryScreenState();
}

class _PromptLibraryScreenState
    extends State<PromptLibraryScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  final List<String> _categories = [
    'All',
    'social_media',
    'business',
    'creative',
    'writing',
    'coding',
    'marketing',
    'education',
    'festival',
  ];

  @override
  void initState() {
    super.initState();
    // ✅ FIXED — loadPrompts() called correctly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromptProvider>().loadPrompts();

      // Load saved prompt ids
      final userId =
          context.read<UserProvider>().user?.uid ?? '';
      if (userId.isNotEmpty) {
        context
            .read<PromptProvider>()
            .loadSavedPromptIds(userId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promptProvider =
    context.watch<PromptProvider>();
    final user = context.watch<UserProvider>().user;
    final isPremium =
        context.watch<UserProvider>().isPremium;
    final userId = user?.uid ?? '';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '📚 Prompt Library',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          // ✅ FIXED — uses allPrompts getter
                          '${promptProvider.allPrompts.length}+ prompts',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── Search Bar ────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.06),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) =>
                            promptProvider
                                .searchPrompts(val),
                        decoration:
                        const InputDecoration(
                          hintText: 'Search prompts...',
                          hintStyle: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppColors.textLight,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Category Filter ────────────────
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    // ✅ FIXED — uses selectedCategory getter
                    final isSelected =
                        promptProvider
                            .selectedCategory ==
                            cat;
                    return GestureDetector(
                      // ✅ FIXED — uses filterByCategory()
                      onTap: () => promptProvider
                          .filterByCategory(cat),
                      child: AnimatedContainer(
                        duration: const Duration(
                            milliseconds: 200),
                        margin: const EdgeInsets.only(
                            right: 8),
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? AppColors.primaryGradient
                              : null,
                          color: isSelected
                              ? null
                              : Colors.white,
                          borderRadius:
                          BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.05),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          cat == 'All'
                              ? 'All ✨'
                              : cat
                              .replaceAll('_', ' ')
                              .toUpperCase()
                              .substring(0, 1)
                              .toUpperCase() +
                              cat
                                  .replaceAll(
                                  '_', ' ')
                                  .substring(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textMedium,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ── Prompts List ──────────────────
              Expanded(
                child: promptProvider.isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
                // ✅ FIXED — uses filteredPrompts getter
                    : promptProvider
                    .filteredPrompts.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(
                      horizontal: 20),
                  // ✅ FIXED — uses filteredPrompts getter
                  itemCount: promptProvider
                      .filteredPrompts.length,
                  itemBuilder:
                      (context, index) {
                    final prompt =
                    promptProvider
                        .filteredPrompts[index];
                    return PromptCard(
                      prompt: prompt,
                      isPremiumUser: isPremium,
                      // ✅ FIXED — uses isPromptSaved()
                      isSaved: promptProvider
                          .isPromptSaved(
                          prompt.id),
                      // ✅ FIXED — uses toggleSavePrompt()
                      onSave: userId.isNotEmpty
                          ? () => promptProvider
                          .toggleSavePrompt(
                          prompt,
                          userId)
                          : null,
                      // ✅ FIXED — onTap navigates to detail
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍',
              style: TextStyle(fontSize: 50)),
          const SizedBox(height: 12),
          const Text(
            'No prompts found!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a different search or category',
            style: TextStyle(
              color: AppColors.textMedium,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _searchController.clear();
              context
                  .read<PromptProvider>()
                  .filterByCategory('All');
            },
            child: const Text(
              'Clear filters',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}