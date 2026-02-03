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

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
    this.validator,
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
              border: InputBorder.none, // Remove bordas padrão
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                // Borda foco sutil
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                borderSide: BorderSide(
                  color: AppColors.surface.withOpacity(0.5),
                  width: 1,
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
