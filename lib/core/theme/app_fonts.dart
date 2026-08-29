import 'package:flutter/material.dart';

/// Brand typefaces — DIN Next LT EN + DIN Next LT Arabic.
class AppFonts {
  AppFonts._();

  static const String english = 'DINNextEnglish';
  static const String arabic = 'DINNextArabic';

  /// Legacy aliases.
  static const String fontFamily = english;
  static const String bbhFontFamily = arabic;

  static String familyForLocale(Locale? locale) =>
      locale?.languageCode == 'ar' ? arabic : english;

  static List<String> fallbackForLocale(Locale? locale) =>
      locale?.languageCode == 'ar' ? const [english] : const [arabic];

  /// Default app text style (English primary, Arabic fallback for mixed text).
  static TextStyle text({
    double? fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    Color? decorationColor,
    FontStyle? fontStyle,
    bool preferArabic = false,
  }) {
    return TextStyle(
      fontFamily: preferArabic ? arabic : english,
      fontFamilyFallback: preferArabic
          ? const [english]
          : const [arabic],
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: decorationColor,
      fontStyle: fontStyle,
    );
  }

  static TextTheme textThemeFor(Locale? locale, {Color? bodyColor}) {
    final family = familyForLocale(locale);
    final fallback = fallbackForLocale(locale);
    final base = ThemeData(brightness: Brightness.dark).textTheme.apply(
          fontFamily: family,
          fontFamilyFallback: fallback,
          bodyColor: bodyColor,
          displayColor: bodyColor,
        );
    return base;
  }
}
