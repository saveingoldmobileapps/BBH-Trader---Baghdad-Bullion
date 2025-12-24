import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saveingold_fzco/core/core_export.dart';

import '../../l10n/app_localizations.dart';

class AlreadyHaveAccountText extends StatelessWidget {
  final VoidCallback onTap;
  final double? fontSize;
  final FontWeight regularWeight;
  final FontWeight boldWeight;
  final Color? regularColor;
  final Color? boldColor;
  final TextAlign? textAlign;

  const AlreadyHaveAccountText({
    super.key,
    required this.onTap,
    this.fontSize,
    this.regularWeight = FontWeight.w400,
    this.boldWeight = FontWeight.w700,
    this.regularColor,
    this.boldColor,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFontSize = fontSize ?? sizes!.responsiveFont(
      phoneVal: 14,
      tabletVal: 16,
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: AppLocalizations.of(
              context,
            )!.already_have_account,
            //  'Already have an account? ',
            style: TextStyle(
              color: regularColor ?? AppColors.neutral90,
              fontSize: effectiveFontSize,
              fontFamily: GoogleFonts.roboto().fontFamily,
              fontWeight: regularWeight,
            ),
          ),
          TextSpan(
            text: AppLocalizations.of(
              context,
            )!.login,
            // 'Login',
            recognizer: TapGestureRecognizer()..onTap = onTap,
            style: TextStyle(
              color: boldColor ?? AppColors.primaryGold500,
              fontSize: effectiveFontSize,
              fontFamily: GoogleFonts.roboto().fontFamily,
              fontWeight: boldWeight,
            ),
          ),
          TextSpan(
            text: '.',
            style: TextStyle(
              color: boldColor ?? AppColors.primaryGold500,
              fontSize: effectiveFontSize,
              fontFamily: GoogleFonts.roboto().fontFamily,
              fontWeight: regularWeight,
            ),
          ),
        ],
      ),
      textAlign: textAlign ?? TextAlign.right,
    );
  }
}