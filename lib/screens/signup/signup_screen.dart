// lib/screens/signup/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added this import
import 'package:provider/provider.dart';
import 'package:lumixo/services/auth_service.dart';
import 'package:lumixo/providers/user_provider.dart';
import 'package:lumixo/utils/colors.dart';
import 'package:lumixo/utils/constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;

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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    final User? user = await _authService.signInWithGoogle();

    if (!mounted) return;

    if (user != null) {
      // No need to navigate here, AuthWrapper will handle it
    } else {
      _showSnack('❌ Google Sign-In failed! Try again.', isError: true);
    }

    if (mounted) {
      setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _emailSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (cred.user != null) {
        await cred.user!.updateDisplayName(_nameController.text.trim());

        // Create user in Firestore
        await _authService.createUser(
          cred.user!.uid,
          {
            'uid': cred.user!.uid,
            'name': _nameController.text.trim(),
            'email': cred.user!.email,
            'photo_url': '',
            'coins': 0,
            'is_premium': false,
            'premium_expiry': null,
            'free_edits_today': 0,
            'last_edit_date': '',
            'total_edits': 0,
            'created_at': FieldValue.serverTimestamp(),
          },
        );

        // No need to navigate, AuthWrapper will handle it.
      }
    } on FirebaseAuthException catch (e) {
      _showSnack(_firebaseError(e.code), isError: true);
    } catch (e) {
      _showSnack('❌ Sign up failed! Try again.', isError: true);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.errorColor : AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _firebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return '❌ This email is already in use! Try logging in.';
      case 'weak-password':
        return '❌ Password is too weak! Try a stronger one.';
      case 'invalid-email':
        return '❌ Invalid email address!';
      default:
        return '❌ Something went wrong! Try again.';
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
                    _buildLogo(),
                    const SizedBox(height: 16),
                    Text(
                      'Create Account',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Start your AI transformation journey',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 36),
                    _buildNameField(),
                    const SizedBox(height: 14),
                    _buildEmailField(),
                    const SizedBox(height: 14),
                    _buildPasswordField(),
                    const SizedBox(height: 24),
                    _buildSignupButton(),
                    const SizedBox(height: 20),
                    _buildDivider(),
                    const SizedBox(height: 20),
                    _buildGoogleButton(),
                    const SizedBox(height: 28),
                    _buildGoToLogin(),
                    const SizedBox(height: 32),
                    const Text(
                      'By signing up you agree to our Terms & Privacy Policy',
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

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildNameField() {
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
        controller: _nameController,
        style: const TextStyle(color: AppColors.textDark, fontSize: 14),
        decoration: InputDecoration(
          labelText: 'Your Name',
          labelStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
          hintText: 'Enter your full name',
          hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
          prefixIcon: _fieldIcon(Icons.person_outline_rounded),
          border: _fieldBorder(),
          enabledBorder: _fieldBorder(),
          focusedBorder: _focusBorder(),
          errorBorder: _errorBorder(),
          focusedErrorBorder: _errorBorder(),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (val) {
          if (val == null || val.trim().isEmpty) {
            return 'Please enter your name';
          }
          return null;
        },
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
          labelStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
          hintText: 'you@example.com',
          hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
          prefixIcon: _fieldIcon(Icons.email_outlined),
          border: _fieldBorder(),
          enabledBorder: _fieldBorder(),
          focusedBorder: _focusBorder(),
          errorBorder: _errorBorder(),
          focusedErrorBorder: _errorBorder(),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          labelStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
          hintText: 'Create a strong password',
          hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
          prefixIcon: _fieldIcon(Icons.lock_outline_rounded),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (val) {
          if (val == null || val.trim().isEmpty) {
            return 'Please create a password';
          }
          if (val.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSignupButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _emailSignup,
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
              ? const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.white),
          )
              : const Text(
            'Create Account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
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
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Center(
          child: _isGoogleLoading
              ? const CircularProgressIndicator()
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.g_mobiledata_rounded, color: AppColors.textDark, size: 32),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'Sign up with Google',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.grey[300]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.grey[300]),
        ),
      ],
    );
  }

  Widget _buildGoToLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(color: AppColors.textMedium, fontSize: 13),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Login',
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

  InputBorder _fieldBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    );
  }

  InputBorder _focusBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    );
  }

  InputBorder _errorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.errorColor, width: 1.5),
    );
  }

  Widget _fieldIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Icon(icon, color: AppColors.textLight, size: 20),
    );
  }
}