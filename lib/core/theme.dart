import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const background = Color(0xFF0F1220);
  static const navigation = Color(0xFF14182A);
  static const card = Color(0xFF1A1E30);
  static const border = Color(0xFF2A2F47);
  static const text = Color(0xFFF2F4FA);
  static const muted = Color(0xFFA9B0C9);
  static const mint = Color(0xFF5EEAD4);
}

ThemeData buildAppTheme() {
  const scheme = ColorScheme.dark(
    primary: AppColors.mint,
    onPrimary: AppColors.background,
    surface: AppColors.card,
    onSurface: AppColors.text,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.navigation,
      indicatorColor: AppColors.card,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(color: AppColors.muted, fontSize: 11),
      ),
    ),
  );
}
