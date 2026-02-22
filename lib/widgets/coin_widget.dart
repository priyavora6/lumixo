import 'package:flutter/material.dart';
import '../utils/colors.dart';

class CoinWidget extends StatelessWidget {
  final int coins;
  final bool showLabel;

  const CoinWidget({
    super.key,
    required this.coins,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/premium'),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.coinColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.coinColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🪙', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              coins.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.coinColor,
              ),
            ),
            if (showLabel) ...[
              const SizedBox(width: 4),
              const Text(
                'coins',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.coinColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}