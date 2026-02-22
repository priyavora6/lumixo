import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/prompt_provider.dart';
import '../../models/category_model.dart';
import '../../widgets/category_card.dart'; // Ensure this import is correct
import '../../widgets/prompt_card.dart';
import '../../widgets/coin_widget.dart';
import '../../utils/colors.dart';
import '../../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.loadUser();
    context.read<CategoryProvider>().loadCategories();
    final promptProvider = context.read<PromptProvider>();
    await promptProvider.loadPrompts();
    if (userProvider.user != null) {
      await promptProvider.loadSavedPromptIds(userProvider.user!.uid);
    }
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
              _buildAppBar(),
              _buildTabs(),
              Expanded(
                child: _currentTab == 0
                    ? _buildAITransformTab()
                    : _buildPromptLibraryTab(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar() {
    final user =
        context.watch<UserProvider>().user;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          20, 16, 20, 8),
      child: Row(
        children: [
          // Logo small
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary
                      .withOpacity(0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Hi ${user?.name.split(' ').first ?? 'there'} 👋',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Text(
                'What do you want today?',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Coins
          CoinWidget(coins: user?.coins ?? 0),

          const SizedBox(width: 8),

          // Notifications
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textDark,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildTab(0, '🤖 AI Transform'),
            _buildTab(1, '📚 Prompt Library'),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final bool isSelected = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            setState(() => _currentTab = index),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: isSelected
                ? AppColors.primaryGradient
                : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : AppColors.textMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAITransformTab() {
    final categories =
        context.watch<CategoryProvider>().categories;
    final isLoading = context
        .watch<CategoryProvider>()
        .isLoadingCategories;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Surprise Me button
          _buildSurpriseMe(),

          const SizedBox(height: 20),

          const Text(
            'Choose Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),

          const SizedBox(height: 14),

          // Categories grid
          GridView.builder(
            shrinkWrap: true,
            physics:
            const NeverScrollableScrollPhysics(),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return CategoryCard(
                category: categories[index],
                onTap: () => _onCategoryTap(
                    categories[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSurpriseMe() {
    return GestureDetector(
      onTap: _onSurpriseMe,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          children: [
            Text('🎲',
                style: TextStyle(fontSize: 32)),
            SizedBox(width: 14),
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Surprise Me! ✨',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Random style applied to your photo',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptLibraryTab() {
    final user = context.read<UserProvider>().user;

    return Column(
      children: [
        // Search and filter
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Row(
            children: [
              // Search bar
              Expanded(
                child: TextField(
                  onChanged: (value) =>
                      context.read<PromptProvider>().searchPrompts(value),
                  decoration: InputDecoration(
                    hintText: 'Search prompts...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Saved button
              IconButton(
                icon: const Icon(Icons.bookmark_border_rounded),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.savedPrompts),
              ),
              // Filter button
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: _showFilterMenu,
              ),
            ],
          ),
        ),

        // Prompt list
        Expanded(
          child: Consumer<PromptProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (provider.filteredPrompts.isEmpty) {
                return const Center(child: Text('No prompts found.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: provider.filteredPrompts.length,
                itemBuilder: (context, index) {
                  final prompt = provider.filteredPrompts[index];
                  return PromptCard(
                    prompt: prompt,
                    isSaved: provider.isPromptSaved(prompt.id),
                    onSave: () => provider.toggleSavePrompt(prompt, user!.uid),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFilterMenu() {
    final promptProvider = context.read<PromptProvider>();
    final categories = ['All'] +
        promptProvider.allPrompts.map((p) => p.category).toSet().toList();

    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 150, 0, 0),
      items: categories.map((category) {
        return PopupMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        promptProvider.filterByCategory(value);
      }
    });
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.pushNamed(
                  context, AppRoutes.promptLibrary);
              break;
            case 2:
              Navigator.pushNamed(
                  context, AppRoutes.history);
              break;
            case 3:
              Navigator.pushNamed(
                  context, AppRoutes.profile);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_rounded),
            label: 'Transform',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline_rounded),
            label: 'Prompts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _onCategoryTap(CategoryModel category) {
    context
        .read<CategoryProvider>()
        .selectCategory(category);
    Navigator.pushNamed(
      context,
      AppRoutes.category,
      arguments: category,
    );
  }

  void _onSurpriseMe() {
    Navigator.pushNamed(
        context, AppRoutes.upload);
  }
}