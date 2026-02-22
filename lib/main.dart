// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/category_provider.dart';
import 'providers/prompt_provider.dart';
import 'services/notification_service.dart';
import 'screens/splash/splash_screen.dart';
import 'utils/colors.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    if (Firebase.apps.isEmpty) {
      // ✅ Initialize Firebase (only once)
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase initialized successfully');

      // ✅ Initialize Firebase App Check
      await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
      debugPrint('✅ Firebase App Check initialized successfully');
    } else {
      debugPrint("✅ Firebase has already been initialized.");
    }

    // ✅ Initialize NotificationService after Firebase
    await NotificationService().initialize();
    debugPrint('✅ NotificationService initialized successfully');
  } catch (e) {
    debugPrint('❌ Error during initialization: $e');
  }

  // Run app
  runApp(const LumixoApp());
}

class LumixoApp extends StatelessWidget {
  const LumixoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        // User Provider
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),

        // Category Provider
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(),
        ),

        // Prompt Provider
        ChangeNotifierProvider(
          create: (_) => PromptProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Lumixo - AI Photo Transform',
        debugShowCheckedModeBanner: false,

        // Theme
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: AppColors.textDark),
            titleTextStyle: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // Routes
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.generateRoute,

        // Unknown route handler
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => const SplashScreen(),
          );
        },
      ),
    );
  }
}
