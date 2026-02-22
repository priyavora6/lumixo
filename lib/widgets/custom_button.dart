import 'package:flutter/material.dart';
import '../utils/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isGoogle;
  final bool isOutlined;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isGoogle = false,
    this.isOutlined = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: isOutlined ? Colors.white : (isGoogle ? Colors.white : AppColors.primary),
      foregroundColor: isOutlined ? AppColors.primary : (isGoogle ? AppColors.textDark : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      side: isOutlined ? const BorderSide(color: AppColors.primary, width: 1.5) : (isGoogle ? BorderSide(color: AppColors.textLight.withOpacity(0.5)) : null),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      elevation: isOutlined ? 0 : (isGoogle ? 1 : 2),
    );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isGoogle)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Image.asset('assets/icons/google.png', height: 20.0, width: 20.0),
                  ),
                Text(
                  text,
                  style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
    );
  }
}
