import 'package:flutter/material.dart';

class LabColors {
  static const navy = Color(0xFF0B2744);
  static const navyDeep = Color(0xFF071A30);
  static const teal = Color(0xFF2EC4B6);
  static const tealDark = Color(0xFF1A8F86);
  static const cream = Color(0xFFEDF3FA);
  static const ink = Color(0xFF1C2B3A);
  static const muted = Color(0xFF5B6B7C);
  static const card = Color(0xFFFFFFFF);
  static const silicon = Color(0xFF2563EB);
  static const germanium = Color(0xFFB56309);
}

ThemeData buildLabTheme() {
  const scheme = ColorScheme.light(
    primary: LabColors.silicon,
    onPrimary: Colors.white,
    secondary: LabColors.teal,
    onSecondary: LabColors.navyDeep,
    surface: LabColors.card,
    onSurface: LabColors.ink,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: LabColors.cream,
    fontFamily: 'Segoe UI',
    dividerColor: const Color(0xFFDCE5EF),
    segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? Colors.white
              : LabColors.navy),
      backgroundColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? LabColors.navy
              : Colors.white),
      side: const WidgetStatePropertyAll(BorderSide(color: Color(0xFFCCD8E5))),
      padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
    )),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: LabColors.navy,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 66,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: LabColors.silicon,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: LabColors.navy,
        side: const BorderSide(color: LabColors.navy, width: 1.4),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    cardTheme: CardThemeData(
      color: LabColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: LabColors.navy.withValues(alpha: 0.10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LabColors.teal, width: 2),
      ),
    ),
  );
}
