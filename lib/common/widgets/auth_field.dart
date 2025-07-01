import 'package:flutter/material.dart';
import 'package:hackathlone_app/core/theme.dart';

class AuthField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLines;
  final String? Function(String?)? validator;
  final bool enableVisibilityToggle;
  final ValueChanged<bool>? onVisibilityChanged;
  final bool isVisible;
  final bool enabled;

  const AuthField({
    super.key,
    required this.label,
    this.hintText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.enableVisibilityToggle = false,
    this.onVisibilityChanged,
    this.isVisible = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    bool localIsVisible = isVisible;
    return TextFormField(
      controller: controller,
      obscureText:
          obscureText && (enableVisibilityToggle ? !localIsVisible : true),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      enabled: enabled,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF131212),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: AppColors.electricBlue,
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
        suffixIcon: enableVisibilityToggle
            ? Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Icon(
                    localIsVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    localIsVisible = !localIsVisible;
                    if (onVisibilityChanged != null) {
                      onVisibilityChanged!(localIsVisible);
                    }
                  },
                ),
              )
            : null,
      ),
    );
  }
}
