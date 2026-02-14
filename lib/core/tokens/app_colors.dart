import 'package:flutter/material.dart';

class AppColors {
  // Cores Principais
  static const Color primary = Color(0xFF08B078); // Verde Principal
  static const Color secondary = Color(0xFF094EF8); // Azul Accent
  static const Color primaryDark = Color(
    0xFF056F4C,
  ); // Verde Escuro para variações

  // Cores Neutras
  static const Color background = Color(0xFFF8F9FA); // Fundo claro mais suave
  static const Color backgroundDark = Color(0xFF121212); // Fundo Grafite Escuro
  static const Color surface = Color(0xFFFFFFFF); // Branco
  static const Color surfaceDark = Color(0xFF121212); // Superficie Grafite
  static const Color textPrimary = Color(0xFF212121); // Preto Suave
  static const Color textPrimaryDark = Color(0xFFF5F5F5); // Branco Suave
  static const Color textSecondary = Color(0xFF757575); // Cinza Médio
  static const Color error = Color(0xFFD32F2F); // Vermelho
  static const Color backgroundLight = Color(0xFFEEEEEE); // Cinza Claro Fundo
  static const Color backgroundLightDark = Color(
    0xFF1E1E1E,
  ); // Cinza Escuro Fundo (Elevado)
  static const Color chatBackground = Color(0xFFE5F0EB); // Fundo Chat
  static const Color chatBackgroundDark = Color(
    0xFF121212,
  ); // Fundo Chat Grafite Escuro

  // Glassmorphism / Liquid Glass
  static Color glassBackground = const Color(0xFFFFFFFF).withValues(alpha: 0.1);
  static Color glassBorder = const Color(0xFFFFFFFF).withValues(alpha: 0.2);

  // Construtor privado
  AppColors._();
}
