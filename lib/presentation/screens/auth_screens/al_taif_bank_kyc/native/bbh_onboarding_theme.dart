import 'package:baghdad_bullion_house/core/theme/app_fonts.dart';
import 'package:baghdad_bullion_house/core/theme/const_colors.dart';
import 'package:flutter/material.dart';

/// BBH onboarding design tokens (brand golds + DIN Next).
abstract final class BbhOnboardingColors {
  static const cream = Color(0xFFF6F0E2);
  static const creamDeep = Color(0xFFEDE4CF);
  static const paper = Color(0xFFFBF8F1);
  static const paperWarm = Color(0xFFF9F3E4);
  static const ink = AppColors.brandDark;
  static const inkSoft = Color(0xFF2C3A52);
  static const gold = AppColors.brandGold2;
  static const goldLight = AppColors.brandGold3;
  static const goldDeep = AppColors.brandGold1;
  static const muted = Color(0xFF8A7E6B);
  static const muted2 = Color(0xFFA59A85);
  static const rule = Color(0xFFE0D5BD);
  static const ruleSoft = Color(0xFFEBE2CC);
  static const error = Color(0xFF8B2E2E);
  static const success = Color(0xFF4A6741);
  static const coverDarkTop = AppColors.brandDark;
  static const coverDarkMid = Color(0xFF1F1F1F);
  static const coverDarkBottom = Color(0xFF0B0B0B);
  static const coverText = AppColors.brandGold3;
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
      AppFonts.text(
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
    double? letterSpacing,
    String? fontFamily,
  }) =>
      AppFonts.text(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        
      );

  static TextStyle arabic({
    double size = 16,
    FontWeight weight = FontWeight.w400,
    Color color = BbhOnboardingColors.ink,
    String? fontFamily,
  }) =>
      AppFonts.text(
        fontSize: size,
        fontWeight: weight,
        color: color,
        preferArabic: true,
      );

  static TextStyle stepEyebrow({bool isArabic = false}) => isArabic
      ? arabic(
          size: 13,
          weight: FontWeight.w700,
          color: BbhOnboardingColors.goldDeep,
        )
      : manrope(
          size: 10,
          weight: FontWeight.w600,
          color: BbhOnboardingColors.goldDeep,
          letterSpacing: 2.2,
        );

  static TextStyle stepTitle({bool isArabic = false}) => isArabic
      ? arabic(
          size: 30,
          weight: FontWeight.w700,
          color: BbhOnboardingColors.ink,
        )
      : display(size: 30, weight: FontWeight.w600);

  static TextStyle stepLede() =>
      manrope(size: 14.5, color: BbhOnboardingColors.muted, height: 1.55);

  static TextStyle fieldLabel() => manrope(
        size: 10,
        weight: FontWeight.w600,
        color: BbhOnboardingColors.goldDeep,
        letterSpacing: 1.8,
      );

  static TextStyle fieldHint() => display(
        size: 13,
        color: BbhOnboardingColors.muted,
      ).copyWith(fontStyle: FontStyle.italic);
}

/// Isolated Material theme so app-wide defaults cannot wash out onboarding text.
abstract final class BbhOnboardingTheme {
  BbhOnboardingTheme._();

  static ThemeData materialTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppFonts.english,
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
        bodySmall:
            BbhOnboardingText.manrope(color: BbhOnboardingColors.inkSoft),
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
