import 'package:flutter/material.dart';

class AppColors {
  // Cores Principais
  static const Color primary = Color(0xFF08B078); // Verde Principal
  static const Color secondary = Color(0xFF094EF8); // Azul Accent
  static const Color primaryDark = Color(
    0xFF056F4C,
  ); // Verde Escuro para variações

  // Cores Neutras
  static const Color background = Color(0xFF1A1A1A); // Fundo escuro padrão
  static const Color surface = Color(0xFFFFFFFF); // Branco
  static const Color textPrimary = Color(0xFF212121); // Preto Suave
  static const Color textSecondary = Color(0xFF757575); // Cinza Médio
  static const Color error = Color(0xFFD32F2F); // Vermelho
  static const Color backgroundLight = Color(0xFFEEEEEE); // Cinza Claro Fundo

  // Glassmorphism / Liquid Glass
  static Color glassBackground = const Color(0xFFFFFFFF).withValues(alpha: 0.1);
  static Color glassBorder = const Color(0xFFFFFFFF).withValues(alpha: 0.2);

  // Construtor privado
  AppColors._();
}
