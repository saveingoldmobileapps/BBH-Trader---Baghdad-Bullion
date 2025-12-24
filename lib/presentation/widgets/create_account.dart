import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saveingold_fzco/core/res_sizes/res.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';

class CreateAccountText extends StatelessWidget {
  final VoidCallback onTap;
  final double? fontSize;
  final FontWeight regularWeight;
  final FontWeight boldWeight;
  final Color? regularColor;
  final Color? boldColor;
  final TextAlign? textAlign;

  const CreateAccountText({
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
            text: AppLocalizations.of(context)!.dont_have_account,//'Don\'t have an account? ',
            style: TextStyle(
              color: regularColor ?? const Color(0xFF939090), // Neutral90 equivalent
              fontSize: effectiveFontSize,
              fontFamily: GoogleFonts.roboto().fontFamily,
              fontWeight: regularWeight,
            ),
          ),
          TextSpan(
            text: AppLocalizations.of(context)!.create_account,//'Create Account',
            recognizer: TapGestureRecognizer()..onTap = onTap,
            style: TextStyle(
              color: boldColor ?? const Color(0xFFBBA473), // PrimaryGold500 equivalent
              fontSize: effectiveFontSize,
              fontFamily: GoogleFonts.roboto().fontFamily,
              fontWeight: boldWeight,
            ),
          ),
          TextSpan(
            text: '.',
            style: TextStyle(
              color: boldColor ?? const Color(0xFFBBA473), // PrimaryGold500 equivalent
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