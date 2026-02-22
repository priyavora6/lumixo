import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:lumixo/services/auth_service.dart';
import 'package:lumixo/providers/user_provider.dart';
import 'package:lumixo/utils/colors.dart';
import 'package:lumixo/utils/constants.dart';
import 'package:lumixo/screens/signup/signup_screen.dart';
import 'package:lumixo/screens/admin/seed_data_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  // ─── ADMIN EMAIL ──────────────────────────────────
  static const String _adminEmail = 'lumixo.app@gmail.com';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;

  // ─── SEED BUTTON VISIBILITY ───────────────────────
  bool _showSeedButton = false;
  int _logoTapCount = 0;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _slideAnim = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();

    // Listen to email changes
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ─── AUTO-DETECT ADMIN EMAIL ──────────────────────
  void _onEmailChanged() {
    final typed = _emailController.text.trim().toLowerCase();
    final isAdmin = typed == _adminEmail.toLowerCase();

    if (isAdmin != _showSeedButton) {
      setState(() => _showSeedButton = isAdmin);
    }
  }

  // ─── SECRET: TAP LOGO 7 TIMES ────────────────────
  void _onLogoTap() {
    _logoTapCount++;

    if (_logoTapCount == 5) {
      _showSnack('2 more taps...', isError: false);
    }

    if (_logoTapCount >= 7) {
      _logoTapCount = 0;
      setState(() => _showSeedButton = !_showSeedButton);
      _showSnack(
        _showSeedButton ? '🔓 Seed button revealed!' : '🔒 Seed button hidden!',
      );
    }
  }

  // ─── GOOGLE LOGIN ─────────────────────────────────
  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    final User? user = await _authService.signInWithGoogle();

    if (!mounted) return;

    if (user != null) {
      await context.read<UserProvider>().loadUser();
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showSnack('❌ Google Sign-In failed! Try again.', isError: true);
    }

    setState(() => _isGoogleLoading = false);
  }

  // ─── EMAIL LOGIN ──────────────────────────────────
  Future<void> _emailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final UserCredential cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (cred.user != null) {
        await context.read<UserProvider>().loadUser();
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      _showSnack(_firebaseError(e.code), isError: true);
    } catch (e) {
      // ignore: avoid_print
      print('Generic error during login: $e');
      _showSnack('An unexpected error occurred.', isError: true);
    }

    setState(() => _isLoading = false);
  }

  // ─── FORGOT PASSWORD ──────────────────────────────
  Future<void> _forgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showSnack('Enter your email first!', isError: true);
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      _showSnack('✅ Password reset link sent to your email!');
    } catch (_) {
      _showSnack('Failed to send reset email!', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
        isError ? AppColors.errorColor : AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _firebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return '❌ No account found! Please sign up.';
      case 'wrong-password':
        return '❌ Wrong password! Try again.';
      case 'invalid-email':
        return '❌ Invalid email address!';
      case 'too-many-requests':
        return '❌ Too many attempts! Try later.';
      case 'user-disabled':
        return '❌ This account has been disabled!';
      case 'network-request-failed':
        return '❌ Network error! Check your internet connection.';
      default:
        return '❌ Something went wrong! ($code)';
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) => Opacity(
                opacity: _fadeAnim.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnim.value),
                  child: child,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 48),

                    // ── Logo (tap 7x = secret seed toggle) ──
                    GestureDetector(
                      onTap: _onLogoTap,
                      child: _buildLogo(),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      AppConstants.appName,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      AppConstants.appTagline,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMedium,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 36),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Welcome back! 👋',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Login to continue your transformation journey',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildEmailField(),

                    const SizedBox(height: 14),

                    _buildPasswordField(),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _forgotPassword,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    _buildLoginButton(),

                    const SizedBox(height: 20),

                    _buildDivider(),

                    const SizedBox(height: 20),

                    _buildGoogleButton(),

                    const SizedBox(height: 28),

                    _buildGoToSignup(),

                    const SizedBox(height: 32),

                    // ── SEED BUTTON — ONLY VISIBLE FOR ADMIN ──
                    if (_showSeedButton) ...[
                      _buildSeedButton(),
                      const SizedBox(height: 16),
                    ],

                    const Text(
                      'By signing in you agree to our Terms & Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── WIDGET BUILDERS ─────────────────────────────

  Widget _buildLogo() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
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
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: AppColors.textDark, fontSize: 14),
        decoration: InputDecoration(
          labelText: 'Email Address',
          labelStyle:
          const TextStyle(color: AppColors.textLight, fontSize: 13),
          hintText: 'you@example.com',
          hintStyle:
          const TextStyle(color: AppColors.textLight, fontSize: 13),
          prefixIcon: _fieldIcon(Icons.email_outlined),
          border: _fieldBorder(),
          enabledBorder: _fieldBorder(),
          focusedBorder: _focusBorder(),
          errorBorder: _errorBorder(),
          focusedErrorBorder: _errorBorder(),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (val) {
          if (val == null || val.trim().isEmpty) {
            return 'Please enter your email';
          }
          if (!val.contains('@') || !val.contains('.')) {
            return 'Enter a valid email address';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
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
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(color: AppColors.textDark, fontSize: 14),
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle:
          const TextStyle(color: AppColors.textLight, fontSize: 13),
          hintText: 'Enter your password',
          hintStyle:
          const TextStyle(color: AppColors.textLight, fontSize: 13),
          prefixIcon: _fieldIcon(Icons.lock_outline_rounded),
          suffixIcon: IconButton(
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textLight,
              size: 20,
            ),
          ),
          border: _fieldBorder(),
          enabledBorder: _fieldBorder(),
          focusedBorder: _focusBorder(),
          errorBorder: _errorBorder(),
          focusedErrorBorder: _errorBorder(),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (val) {
          if (val == null || val.trim().isEmpty) {
            return 'Please enter your password';
          }
          if (val.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _emailLogin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: _isLoading ? null : AppColors.primaryGradient,
          color: _isLoading ? AppColors.primary.withOpacity(0.4) : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isLoading
              ? null
              : [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          )
              : const Text(
            '🚀  Login to Lumixo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.transparent,
                Colors.grey.withOpacity(0.3),
              ]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.grey.withOpacity(0.3),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: _isGoogleLoading ? null : _signInWithGoogle,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isGoogleLoading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.5,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Center(
                  child: Text(
                    'G',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Continue with Google',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoToSignup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?  ",
          style: TextStyle(
            color: AppColors.textMedium,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SignupScreen()),
          ),
          child: const Text(
            'Sign Up Free ✨',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeedButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SeedDataScreen()),
      ),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.orange.withOpacity(0.35),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Text('🌱', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seed Database  ⚠️ Dev Only',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Add all 11 categories to Firestore',
                  style: TextStyle(
                    color: Colors.orange.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.orange.withOpacity(0.5),
              size: 14,
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  // ─── FIELD HELPERS ────────────────────────────────
  Widget _fieldIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.all(11),
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.primary, size: 19),
    );
  }

  OutlineInputBorder _fieldBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide.none,
  );

  OutlineInputBorder _focusBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(
      color: AppColors.primary.withOpacity(0.5),
      width: 1.5,
    ),
  );

  OutlineInputBorder _errorBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(
      color: AppColors.errorColor,
      width: 1.5,
    ),
  );
}
