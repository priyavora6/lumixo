import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ai_service.dart';
import '../../services/firestore_service.dart';
import '../../providers/user_provider.dart';
import '../../utils/colors.dart';
import '../../routes/app_routes.dart';

class ProcessingScreen extends StatefulWidget {
  final String imagePath;
  final String prompt;
  final String styleName;
  final String category;

  const ProcessingScreen({
    super.key,
    required this.imagePath,
    required this.prompt,
    required this.styleName,
    required this.category,
  });

  @override
  State<ProcessingScreen> createState() =>
      _ProcessingScreenState();
}

class _ProcessingScreenState
    extends State<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  final AIService _aiService = AIService();
  final FirestoreService _firestoreService =
  FirestoreService();

  late AnimationController _animController;
  int _messageIndex = 0;

  final List<String> _messages = [
    'Waking up the magic... ✨',
    'Analyzing your photo... 🔍',
    'Applying AI transformation... 🪄',
    'Sprinkling Lumixo magic... 💫',
    'Almost ready... 🌟',
    'Putting final touches... ✨',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startMessageCycle();
    _startTransform();
  }

  void _startMessageCycle() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      setState(() {
        _messageIndex =
            (_messageIndex + 1) % _messages.length;
      });
      return true;
    });
  }

  Future<void> _startTransform() async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    final String? resultUrl =
    await _aiService.transformPhoto(
      imageFile: File(widget.imagePath),
      prompt: widget.prompt,
      userId: user.uid,
    );

    if (!mounted) return;

    if (resultUrl != null) {
      // Update edit count
      await _firestoreService
          .incrementEditCount(user.uid);
      await context.read<UserProvider>().refreshUser();

      // Go to result
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.result,
        arguments: {
          'resultUrl': resultUrl,
          'originalPath': widget.imagePath,
          'styleName': widget.styleName,
          'category': widget.category,
        },
      );
    } else {
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Oops! Something went wrong'),
        content: const Text(
          'AI transformation failed. Please try again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Go Back'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startTransform();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                // Rotating logo
                RotationTransition(
                  turns: _animController,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color:
                      Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary
                              .withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  'Transforming Your Photo',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 12),

                AnimatedSwitcher(
                  duration:
                  const Duration(milliseconds: 500),
                  child: Text(
                    _messages[_messageIndex],
                    key: ValueKey(_messageIndex),
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textMedium,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 48),
                  child: ClipRRect(
                    borderRadius:
                    BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.primary
                          .withOpacity(0.2),
                      valueColor:
                      AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Style info
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.6),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Style: ${widget.styleName}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}