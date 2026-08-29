import 'package:flutter/material.dart';
import 'package:baghdad_bullion_house/core/theme/app_fonts.dart';

import 'funding_portal_theme.dart';

/// Typography from BBH Funding Portal prototype (Manrope, Cormorant Garamond, JetBrains Mono).
abstract final class FundingPortalTypography {
  /// Minimum line-height multiplier for readable, non-overlapping lines.
  static const double _defaultHeight = 1.45;

  static TextStyle manrope({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color color = FundingPortalColors.ink,
    double? letterSpacing,
    double? height,
  }) {
    return AppFonts.text(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height ?? _defaultHeight,
    ).copyWith(leadingDistribution: TextLeadingDistribution.even);
  }

  static TextStyle cormorant({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w600,
    Color color = FundingPortalColors.ink,
    double? letterSpacing,
    double? height,
  }) {
    return AppFonts.text(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height ?? _defaultHeight,
    ).copyWith(leadingDistribution: TextLeadingDistribution.even);
  }

  static TextStyle mono({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w500,
    Color color = FundingPortalColors.ink,
    double? letterSpacing,
    double? height,
  }) {
    return AppFonts.text(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height ?? 1.4,
    ).copyWith(leadingDistribution: TextLeadingDistribution.even);
  }

  static TextStyle appGreeting = manrope(
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    color: FundingPortalColors.muted,
    letterSpacing: 1.5,
    height: 1.5,
  );

  static TextStyle appName = cormorant(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: FundingPortalColors.ink,
    letterSpacing: 1,
    height: 1.2,
  );

  static TextStyle appNameSmall = cormorant(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: FundingPortalColors.ink,
    letterSpacing: 0.4,
    height: 1.25,
  );

  static TextStyle headerTitle = cormorant(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: FundingPortalColors.ink,
    letterSpacing: 0.8,
    height: 1.3,
  );

  static TextStyle bodyMuted = manrope(
    fontSize: 12.5,
    color: FundingPortalColors.muted,
    height: 1.55,
  );

  static TextStyle bodySmallMuted = manrope(
    fontSize: 12,
    color: FundingPortalColors.muted,
    height: 1.55,
  );

  static TextStyle fieldLabel = manrope(
    fontSize: 9.5,
    fontWeight: FontWeight.w600,
    color: FundingPortalColors.muted,
    letterSpacing: 1.5,
    height: 1.5,
  );

  static TextStyle btnPrimary = manrope(
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    color: FundingPortalColors.cream,
    letterSpacing: 1,
    height: 1.3,
  );

  static TextStyle btnSecondary = manrope(
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    color: FundingPortalColors.ink2,
    letterSpacing: 1,
    height: 1.3,
  );

  static TextStyle btnTertiary = manrope(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: FundingPortalColors.muted,
    height: 1.4,
  );
}
