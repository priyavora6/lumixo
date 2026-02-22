// lib/widgets/premium_badge.dart

import 'package:flutter/material.dart';
import 'package:lumixo/utils/colors.dart';

class PremiumBadge extends StatelessWidget {
  final bool isSmall;

  const PremiumBadge({Key? key, this.isSmall = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 10,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(isSmall ? 6 : 8),
        boxShadow: [
          BoxShadow(
            color: AppColors.premiumGold.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '👑 PRO',
        style: TextStyle(
          fontSize: isSmall ? 9 : 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}