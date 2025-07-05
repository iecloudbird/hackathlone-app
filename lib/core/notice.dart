import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, {Color? color}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color ?? Colors.red,
      duration: const Duration(seconds: 3),
    ),
  );
}

void showSuccessSnackBar(BuildContext context, String message) {
  showSnackBar(context, message, color: Colors.green);
}
