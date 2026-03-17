import 'package:flutter/material.dart';

/// Paleta de cores do app Aroma de Hortelã
class AppColors {
  AppColors._();

  // CORES PRINCIPAIS (LARANJA)
  static const Color primary = Color(0xFFE8834A);
  static const Color primaryDark = Color(0xFFD46A2E);
  static const Color primaryLight = Color(0xFFFFF4ED);
  static const Color primarySurface = Color(0xFFFFFBF8);

  // CORES SECUNDÁRIAS (VERDE HORTELÃ)
  static const Color secondary = Color(0xFF8FAE8B);
  static const Color secondaryDark = Color(0xFF6B8F66);
  static const Color secondaryLight = Color(0xFFB5D4B0);

  // CORES DE GRADIENTE
  static const List<Color> gradientOrange = [Color(0xFFE8834A), Color(0xFFD46A2E)];
  static const List<Color> gradientCoral = [Color(0xFFE8834A), Color(0xFFE85A6B)];
  static const List<Color> gradientYellow = [Color(0xFFF5B041), Color(0xFFE8834A)];
  static const List<Color> gradientRed = [Color(0xFFE8834A), Color(0xFFE74C3C)];

  // CORES NEUTRAS
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey900 = Color(0xFF1A1A1A);
  static const Color grey700 = Color(0xFF4A4A4A);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color cream = Color(0xFFFDF8F3);

  // CORES DE STATUS
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFF5B041);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // TEMA CLARO
  static const Color lightBackground = Color(0xFFFDF8F3);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF4A4A4A);
  static const Color lightTextHint = Color(0xFF9E9E9E);
  static const Color lightInputBorder = Color(0xFFE0E0E0);
  static const Color lightInputFocused = Color(0xFFE8834A);
  static const Color lightInputFill = Color(0xFFFFFFFF);

  // TEMA ESCURO (mantido para referência futura)
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color darkDivider = Color(0xFF3D3D3D);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkTextHint = Color(0xFF757575);
  static const Color darkInputBorder = Color(0xFF3D3D3D);
  static const Color darkInputFocused = Color(0xFFE8834A);
  static const Color darkInputFill = Color(0xFF2C2C2C);

  // ESPECÍFICAS DO APP
  static const Color statusActive = Color(0xFF4CAF50);
  static const Color statusActiveBackground = Color(0xFFE8F5E9);
  static const Color statusInactive = Color(0xFF9E9E9E);
  static const Color statusInactiveBackground = Color(0xFFF5F5F5);
  static const Color avatarBackground = Color(0xFFE8834A);
  static const Color avatarText = Color(0xFFFFFFFF);

  // ALIASES (usam light)
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color card = lightCard;
  static const Color divider = lightDivider;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textHint = lightTextHint;
  static const Color textDisabled = grey500;

  // MÉTODO UTILITÁRIO
  static LinearGradient getCardGradient(int index) {
    final gradients = [gradientOrange, gradientCoral, gradientYellow, gradientRed];
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradients[index % gradients.length],
    );
  }
}
