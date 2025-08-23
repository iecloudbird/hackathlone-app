import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Simple toast notification utility using system-like styling
class ToastNotification {
  /// Show a success toast message
  static void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF424242), 
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Show an error toast message
  static void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(
        0xFF424242,
      ), // Same dark gray for consistency
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Show an info toast message
  static void showInfo(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(
        0xFF424242,
      ), // Same dark gray for consistency
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Show a warning toast message
  static void showWarning(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(
        0xFF424242,
      ), // Same dark gray for consistency
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Show a custom toast with specific styling
  static void showCustom({
    required String message,
    Color backgroundColor = Colors.grey,
    Color textColor = Colors.white,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast length = Toast.LENGTH_SHORT,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: length,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 14.0,
    );
  }
}
