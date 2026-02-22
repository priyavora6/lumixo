import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'colors.dart';
import 'constants.dart';

class AppHelpers {
  // Show snackbar
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? AppColors.errorColor : AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Format date
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  // Check if edit expired (free user)
  static bool isEditExpired(DateTime createdAt) {
    final expiryDate = createdAt.add(
      const Duration(days: AppConstants.freeHistoryDays),
    );
    return DateTime.now().isAfter(expiryDate);
  }

  // Days left before expiry
  static int daysUntilExpiry(DateTime createdAt) {
    final expiryDate = createdAt.add(
      const Duration(days: AppConstants.freeHistoryDays),
    );
    return expiryDate.difference(DateTime.now()).inDays;
  }

  // Today's date string
  static String todayString() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // Show loading dialog
  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Check if today
  static bool isToday(String dateString) {
    return dateString == todayString();
  }
}
