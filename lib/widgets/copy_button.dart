// lib/widgets/copy_button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumixo/utils/colors.dart';

class CopyButton extends StatefulWidget {
  final String textToCopy;
  final String label;
  final bool isLarge;

  const CopyButton({
    Key? key,
    required this.textToCopy,
    this.label = 'Copy',
    this.isLarge = false,
  }) : super(key: key);

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.textToCopy));
    HapticFeedback.mediumImpact();

    setState(() => _copied = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Copied to clipboard!'),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLarge) {
      return GestureDetector(
        onTap: _copy,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: _copied ? null : AppColors.primaryGradient,
            color: _copied ? AppColors.successColor : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: (_copied ? AppColors.successColor : AppColors.primary)
                    .withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _copied ? Icons.check_circle : Icons.copy_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  _copied ? 'Copied! ✅' : '📋 ${widget.label}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _copy,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _copied
              ? AppColors.successColor.withOpacity(0.15)
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _copied ? Icons.check : Icons.copy,
              size: 14,
              color: _copied ? AppColors.successColor : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              _copied ? 'Copied!' : widget.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _copied ? AppColors.successColor : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}