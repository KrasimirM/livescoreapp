// widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:LiveScore/constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? errorText;
  final bool obscureText;
  final VoidCallback? toggleVisibility;
  final bool showToggle;

  const CustomTextField({
    required this.controller,
    required this.label,
    this.errorText,
    this.obscureText = false,
    this.toggleVisibility,
    this.showToggle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: AppColors.textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textColor),
          errorText: errorText,
          filled: true,
          fillColor: AppColors.cardBackgroundColor,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryColor),
            borderRadius: BorderRadius.circular(8),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          suffixIcon: showToggle
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.accentColor,
                  ),
                  onPressed: toggleVisibility,
                )
              : null,
        ),
      ),
    );
  }
}
