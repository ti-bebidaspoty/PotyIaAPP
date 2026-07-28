import 'package:flutter/material.dart';

abstract final class AppColors {
  // Cores principais
  static const Color primary = Color(0xFF13795B);
  static const Color primaryDark = Color(0xFF084C3A);
  static const Color primaryDeep = Color(0xFF063B2D);
  static const Color primaryLight = Color(0xFFE8F5EF);
  static const Color primaryContainer = Color(0xFFD5EEE3);

  // Amarelo de apoio
  static const Color secondary = Color(0xFFE6B938);
  static const Color secondaryDark = Color(0xFFC9971A);
  static const Color secondaryLight = Color(0xFFFFF7D6);
  static const Color accent = Color(0xFFF2C94C);

  // Fundos
  static const Color background = Color(0xFFF6F8F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFFAFBFA);
  static const Color surfaceMuted = Color(0xFFF0F3F1);

  // Textos
  static const Color textPrimary = Color(0xFF17211D);
  static const Color textSecondary = Color(0xFF46534D);
  static const Color textMuted = Color(0xFF6C7973);

  // Bordas
  static const Color border = Color(0xFFD2D9D5);
  static const Color borderSoft = Color(0xFFE6EBE8);

  // Estados
  static const Color success = Color(0xFF16875F);
  static const Color successContainer = Color(0xFFE9F8F1);

  static const Color warning = Color(0xFFD99A16);
  static const Color warningContainer = Color(0xFFFFF7E0);

  static const Color error = Color(0xFFD64545);
  static const Color errorContainer = Color(0xFFFFEEEE);

  static const Color info = Color(0xFF3E7C72);
  static const Color infoContainer = Color(0xFFEAF4F2);

  static const Color shadow = Color(0x180B2E23);
}