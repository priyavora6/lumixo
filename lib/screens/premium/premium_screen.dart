import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/payment_service.dart';
import '../../widgets/custom_button.dart';
import '../../utils/colors.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() =>
      _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final PaymentService _paymentService =
  PaymentService();
  bool _isYearly = true;

  @override
  void initState() {
    super.initState();
    _paymentService.initialize();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  void _buyPremium() {
    _paymentService.openPayment(
      isYearly: _isYearly,
      onSuccessCallback: () {
        context.read<UserProvider>().setPremiumLocally();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Welcome to Premium!'),
            backgroundColor: AppColors.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      },
      onErrorCallback: (msg) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $msg'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPremium =
        context.watch<UserProvider>().isPremium;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8E7),
              Color(0xFFFFF0D4),
              Color(0xFFFDE8C8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: AppColors.textDark,
                      ),
                      onPressed: () =>
                          Navigator.pop(context),
                    ),
                    const Spacer(),
                  ],
                ),

                const Text(
                  '👑',
                  style: TextStyle(fontSize: 60),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Lumixo Premium',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Unlimited AI transformations forever',
                  style: TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 28),

                // Benefits
                _buildBenefit(
                    '✅', 'Unlimited AI edits daily'),
                _buildBenefit(
                    '✅', 'HD downloads — no watermark'),
                _buildBenefit(
                    '✅', 'All premium styles unlocked'),
                _buildBenefit(
                    '✅', 'Edit history saved forever'),
                _buildBenefit(
                    '✅', 'Priority AI processing'),
                _buildBenefit(
                    '✅', 'All premium prompts access'),

                const SizedBox(height: 28),

                // Plan toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildPlanToggle(
                        'Monthly',
                        '₹199',
                        false,
                      ),
                      _buildPlanToggle(
                        'Yearly',
                        '₹999',
                        true,
                        badge: 'SAVE 58%',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Buy button
                if (!isPremium)
                  CustomButton(
                    text: _isYearly
                        ? '👑 Get Yearly — ₹999'
                        : '👑 Get Monthly — ₹199',
                    onPressed: _buyPremium,
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient:
                      AppColors.premiumGradient,
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Text('👑',
                            style:
                            TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        Text(
                          'You are already Premium!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                const Text(
                  'Cancel anytime • Secure payment by Razorpay',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit(String emoji, String text) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji,
              style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanToggle(
      String label,
      String price,
      bool isYearly, {
        String? badge,
      }) {
    final bool isSelected = _isYearly == isYearly;

    return Expanded(
      child: GestureDetector(
        onTap: () =>
            setState(() => _isYearly = isYearly),
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected
                ? AppColors.premiumGradient
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                price,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : AppColors.textDark,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? Colors.white70
                      : AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}