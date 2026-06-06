import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens from `bbh-onboarding-demo_22_2.html`.
abstract final class BbhOnboardingColors {
  static const cream = Color(0xFFF6F0E2);
  static const creamDeep = Color(0xFFEDE4CF);
  static const paper = Color(0xFFFBF8F1);
  static const paperWarm = Color(0xFFF9F3E4);
  static const ink = Color(0xFF1C2638);
  static const inkSoft = Color(0xFF2C3A52);
  static const gold = Color(0xFFB8924A);
  static const goldLight = Color(0xFFD4B674);
  static const goldDeep = Color(0xFF8D6C2F);
  static const muted = Color(0xFF8A7E6B);
  static const muted2 = Color(0xFFA59A85);
  static const rule = Color(0xFFE0D5BD);
  static const ruleSoft = Color(0xFFEBE2CC);
  static const error = Color(0xFF8B2E2E);
  static const success = Color(0xFF4A6741);
  static const coverDarkTop = Color(0xFF0A1326);
  static const coverDarkMid = Color(0xFF14213D);
  static const coverDarkBottom = Color(0xFF0B1428);
  static const coverText = Color(0xFFEDE0BC);
}

abstract final class BbhOnboardingRadii {
  static const sm = 6.0;
  static const md = 10.0;
  static const lg = 18.0;
}

abstract final class BbhOnboardingText {
  static TextStyle manrope({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = BbhOnboardingColors.ink,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.manrope(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle display({
    double size = 30,
    FontWeight weight = FontWeight.w600,
    Color color = BbhOnboardingColors.ink,
    double? height,
  }) =>
      GoogleFonts.cormorantGaramond(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  static TextStyle arabic({
    double size = 16,
    FontWeight weight = FontWeight.w400,
    Color color = BbhOnboardingColors.ink,
  }) =>
      GoogleFonts.amiri(fontSize: size, fontWeight: weight, color: color);

  static TextStyle stepEyebrow({bool isArabic = false}) => isArabic
      ? arabic(size: 13, weight: FontWeight.w700, color: BbhOnboardingColors.goldDeep)
      : manrope(
          size: 10,
          weight: FontWeight.w600,
          color: BbhOnboardingColors.goldDeep,
          letterSpacing: 2.2,
        );

  static TextStyle stepTitle({bool isArabic = false}) => isArabic
      ? arabic(size: 30, weight: FontWeight.w700, color: BbhOnboardingColors.ink)
      : display(size: 30, weight: FontWeight.w600);

  static TextStyle stepLede() =>
      manrope(size: 14.5, color: BbhOnboardingColors.muted, height: 1.55);

  static TextStyle fieldLabel() => manrope(
        size: 10,
        weight: FontWeight.w600,
        color: BbhOnboardingColors.goldDeep,
        letterSpacing: 1.6,
      );
}

/// Isolated Material theme so app-wide defaults cannot wash out onboarding text.
abstract final class BbhOnboardingTheme {
  BbhOnboardingTheme._();

  static ThemeData materialTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: BbhOnboardingColors.cream,
      canvasColor: BbhOnboardingColors.cream,
      colorScheme: const ColorScheme.light(
        primary: BbhOnboardingColors.ink,
        onPrimary: BbhOnboardingColors.cream,
        surface: BbhOnboardingColors.cream,
        onSurface: BbhOnboardingColors.ink,
        secondary: BbhOnboardingColors.goldDeep,
        onSecondary: BbhOnboardingColors.cream,
      ),
      textTheme: TextTheme(
        bodyLarge: BbhOnboardingText.manrope(color: BbhOnboardingColors.ink),
        bodyMedium: BbhOnboardingText.manrope(color: BbhOnboardingColors.ink),
        bodySmall: BbhOnboardingText.manrope(color: BbhOnboardingColors.inkSoft),
        titleLarge: BbhOnboardingText.display(color: BbhOnboardingColors.ink),
        labelLarge: BbhOnboardingText.manrope(
          size: 12,
          weight: FontWeight.w700,
          color: BbhOnboardingColors.cream,
          letterSpacing: 1.4,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BbhOnboardingColors.ink,
          foregroundColor: BbhOnboardingColors.cream,
          disabledBackgroundColor: BbhOnboardingColors.muted2,
          disabledForegroundColor: BbhOnboardingColors.paper,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BbhOnboardingColors.ink,
          side: const BorderSide(color: BbhOnboardingColors.rule),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: BbhOnboardingColors.muted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BbhOnboardingColors.paper,
        hintStyle: BbhOnboardingText.manrope(color: BbhOnboardingColors.muted),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: BbhOnboardingColors.goldDeep,
      ),
    );
  }
}
