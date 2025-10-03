import 'package:flutter/material.dart';

class AppUtils {
  // Date formatting
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // QR Code validation
  static bool isValidQRCode(String qrData) {
    if (qrData.isEmpty) return false;

    // Check various QR formats
    return qrData.startsWith('MUSEUM:') ||
           qrData.contains('/artifact/') ||
           RegExp(r'^AR\d{3}$').hasMatch(qrData);
  }

  // Network connectivity check
  static Future<bool> hasInternetConnection() async {
    try {
      // In a real app, you would use connectivity_plus package
      return true;
    } catch (e) {
      return false;
    }
  }

  // Debounce function for search
  static void debounce(Function() action, Duration delay) {
    Future.delayed(delay, action);
  }

  // Show snackbar helper
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
