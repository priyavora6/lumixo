import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {
  final PageController _pageController =
  PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'emoji': '✨',
      'title': 'Browse 500+ AI Prompts',
      'subtitle':
      'Find the perfect prompt for any task — social media, business, creative and more!',
      'color': Color(0xFFB8D4F0),
    },
    {
      'emoji': '🪄',
      'title': 'Transform Your Photo',
      'subtitle':
      'Upload any photo, pick a style, and watch AI magic happen in seconds!',
      'color': Color(0xFFD4B8F0),
    },
    {
      'emoji': '💫',
      'title': 'Download & Share',
      'subtitle':
      'Save your masterpiece in HD and share instantly to WhatsApp, Instagram and more!',
      'color': Color(0xFFF0B8D4),
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        AppConstants.prefOnboardingSeen, true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(
        context, AppRoutes.login);
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
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.textMedium,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              // Indicator
              SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: AppColors.primary,
                  dotColor:
                  AppColors.primary.withOpacity(0.3),
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3,
                ),
              ),

              const SizedBox(height: 32),

              // Button
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24),
                child: CustomButton(
                  text: _currentPage == 2
                      ? 'Get Started ✨'
                      : 'Next →',
                  onPressed: () {
                    if (_currentPage == 2) {
                      _finishOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(
                            milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji in circle
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: (page['color'] as Color)
                  .withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                page['emoji'],
                style: const TextStyle(fontSize: 72),
              ),
            ),
          ),

          const SizedBox(height: 48),

          Text(
            page['title'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            page['subtitle'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textMedium,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
