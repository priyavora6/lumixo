import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumixo/main.dart' as app;
import 'package:lumixo/screens/splash/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:lumixo/providers/user_provider.dart';
import 'package:lumixo/providers/category_provider.dart';
import 'package:lumixo/providers/prompt_provider.dart';

void main() {
  testWidgets('Splash screen shows logo and app name', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => PromptProvider()),
        ],
        child: const app.LumixoApp(),
      ),
    );

    // Verify that the splash screen is shown.
    expect(find.byType(SplashScreen), findsOneWidget);

    // Verify that the app name is present.
    expect(find.text('Lumixo'), findsOneWidget);
  });
}
