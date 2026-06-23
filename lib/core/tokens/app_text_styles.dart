import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';

class AppTextStyles {
  // Brandbook: Barlow — Modern, Clean, Strong, High Readable, Elegant

  /// H1 — Bold 40/48
  static TextStyle get h1 =>
      GoogleFonts.barlow(fontSize: 40, fontWeight: FontWeight.w700, height: 48 / 40);

  /// H2 — Bold 28/36
  static TextStyle get h2 =>
      GoogleFonts.barlow(fontSize: 28, fontWeight: FontWeight.w700, height: 36 / 28);

  /// H3 — SemiBold 20/28
  static TextStyle get h3 =>
      GoogleFonts.barlow(fontSize: 20, fontWeight: FontWeight.w600, height: 28 / 20);

  /// Body Large — Regular 16/24
  static TextStyle get bodyLarge =>
      GoogleFonts.barlow(fontSize: 16, fontWeight: FontWeight.normal, height: 24 / 16);

  /// Body Medium — Regular 14/24
  static TextStyle get bodyMedium =>
      GoogleFonts.barlow(fontSize: 14, fontWeight: FontWeight.normal, height: 24 / 14);

  /// Body Small / Caption — Regular 12/18
  static TextStyle get bodySmall => GoogleFonts.barlow(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 18 / 12,
    color: AppColors.textSecondary,
  );

  /// Caption — Regular 12/18
  static TextStyle get caption => GoogleFonts.barlow(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 18 / 12,
  );

  /// CTA / Button — SemiBold 14/20
  static TextStyle get button =>
      GoogleFonts.barlow(fontSize: 14, fontWeight: FontWeight.w600, height: 20 / 14);

  AppTextStyles._();
}
