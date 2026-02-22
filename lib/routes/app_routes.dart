import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/signup/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/category/category_screen.dart';
import '../screens/style/style_screen.dart';
import '../screens/upload/upload_screen.dart';
import '../screens/processing/processing_screen.dart';
import '../screens/result/result_screen.dart';
import '../screens/prompt_library/prompt_library_screen.dart';
import '../screens/prompt_library/saved_prompts_screen.dart';
import '../screens/prompt_detail/prompt_detail_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/premium/premium_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/about_screen.dart';
import '../screens/settings/privacy_policy_screen.dart';
import '../screens/settings/terms_screen.dart';
import '../models/category_model.dart';
import '../models/style_model.dart';
import '../models/prompt_model.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String category = '/category';
  static const String style = '/style';
  static const String upload = '/upload';
  static const String processing = '/processing';
  static const String result = '/result';
  static const String promptLibrary = '/prompts';
  static const String promptDetail = '/prompts/detail';
  static const String savedPrompts = '/prompts/saved';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String premium = '/premium';
  static const String settings = '/settings';
  static const String about = '/settings/about';
  static const String privacyPolicy = '/settings/privacy-policy';
  static const String terms = '/settings/terms';

  static Map<String, WidgetBuilder> get routes => {
        onboarding: (_) => const OnboardingScreen(),
        login: (_) => const LoginScreen(),
        signup: (_) => const SignupScreen(),
        home: (_) => const HomeScreen(),
        promptLibrary: (_) => const PromptLibraryScreen(),
        savedPrompts: (_) => const SavedPromptsScreen(),
        history: (_) => const HistoryScreen(),
        profile: (_) => const ProfileScreen(),
        premium: (_) => const PremiumScreen(),
        settings: (_) => const SettingsScreen(),
        about: (_) => const AboutScreen(),
        privacyPolicy: (_) => const PrivacyPolicyScreen(),
        terms: (_) => const TermsScreen(),
      };

  // Routes with arguments
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case category:
        final cat = settings.arguments as CategoryModel;
        return MaterialPageRoute(
          builder: (_) => CategoryScreen(category: cat),
        );
      case style:
        final styleModel = settings.arguments as StyleModel;
        return MaterialPageRoute(
          builder: (_) => StyleScreen(style: styleModel),
        );
      case upload:
        final styleModel = settings.arguments as StyleModel;
        return MaterialPageRoute(
          builder: (_) => UploadScreen(style: styleModel),
        );
      case processing:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ProcessingScreen(
            imagePath: args['imagePath'],
            prompt: args['prompt'],
            styleName: args['styleName'],
            category: args['category'],
          ),
        );
      case result:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ResultScreen(
            resultUrl: args['resultUrl'],
            originalPath: args['originalPath'],
            styleName: args['styleName'],
            category: args['category'],
          ),
        );
      case promptDetail:
        final prompt = settings.arguments as PromptModel;
        return MaterialPageRoute(
          builder: (_) => PromptDetailScreen(prompt: prompt),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
    }
  }
}
