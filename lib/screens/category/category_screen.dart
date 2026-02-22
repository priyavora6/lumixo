// lib/screens/category/category_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/style_card.dart';
import '../../utils/colors.dart';
import '../../routes/app_routes.dart';

class CategoryScreen extends StatefulWidget {
  final CategoryModel category;
  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Load styles
    context.read<CategoryProvider>().loadStyles(widget.category.id);

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final styles = context.watch<CategoryProvider>().styles;
    final isLoading = context.watch<CategoryProvider>().isLoadingStyles;
    final isPremium = context.watch<UserProvider>().isPremium;

    final freeStyles = styles.where((s) => !s.isPremium).length;
    final premiumStyles = styles.where((s) => s.isPremium).length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced app bar
              _buildAppBar(context, freeStyles, premiumStyles),

              const SizedBox(height: 16),

              // Stats bar
              if (!isLoading && styles.isNotEmpty)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildStatsBar(
                    styles.length,
                    freeStyles,
                    premiumStyles,
                    isPremium,
                  ),
                ),

              const SizedBox(height: 16),

              // Styles grid
              Expanded(
                child: isLoading
                    ? _buildLoadingGrid()
                    : styles.isEmpty
                    ? _buildEmptyState()
                    : FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildStylesGrid(styles, isPremium),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(
      BuildContext context,
      int freeStyles,
      int premiumStyles,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.category.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.category.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Choose your transformation style',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(
      int total,
      int free,
      int premium,
      bool isPremium,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            Icons.auto_awesome,
            '$total',
            'Total Styles',
            AppColors.primary,
          ),
          const SizedBox(width: 16),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey[300],
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            Icons.check_circle,
            '$free',
            'Free',
            Colors.green,
          ),
          const SizedBox(width: 16),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey[300],
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            Icons.star,
            '$premium',
            'Premium',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon,
      String value,
      String label,
      Color color,
      ) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStylesGrid(List styles, bool isPremium) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: styles.length,
      itemBuilder: (context, index) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                (index * 0.1).clamp(0.0, 1.0),
                ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                curve: Curves.easeOut,
              ),
            ),
          ),
          child: StyleCard(
            style: styles[index],
            isPremiumUser: isPremium,
            onTap: () {
              if (styles[index].isPremium && !isPremium) {
                _showPremiumDialog(context);
              } else {
                context.read<CategoryProvider>().selectStyle(styles[index]);
                Navigator.pushNamed(
                  context,
                  AppRoutes.upload,
                  arguments: styles[index],
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.style_outlined,
            size: 64,
            color: AppColors.textMedium.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No styles available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new styles',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMedium.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: const [
            Icon(Icons.star, color: Colors.orange),
            SizedBox(width: 8),
            Text('Premium Style'),
          ],
        ),
        content: const Text(
          'This style is only available for Premium users. Upgrade now to unlock all premium features!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.premium);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}