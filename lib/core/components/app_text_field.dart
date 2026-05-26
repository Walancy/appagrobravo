import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool hasError;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
    this.validator,
    this.onChanged,
    this.hasError = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            // Fonte ajustada
            color: AppColors.surface.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            onChanged: onChanged,
            keyboardType: keyboardType,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.surface,
            ), // Fonte interna ajustada
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.surface.withOpacity(0.5),
              ),
              filled: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, // Reduzido
                vertical: 14, // Altura reduzida
              ),
              border: hasError 
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
                    )
                  : InputBorder.none,
              enabledBorder: hasError 
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
                    )
                  : InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                borderSide: BorderSide(
                  color: hasError ? Colors.redAccent : AppColors.surface.withOpacity(0.5),
                  width: hasError ? 1.5 : 1,
                ),
              ),
              suffixIcon: suffixIcon,
              suffixIconColor: AppColors.surface,
            ),
          ),
        ),
      ],
    );
  }
}
