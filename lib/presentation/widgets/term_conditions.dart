import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saveingold_fzco/core/core_export.dart';

import '../../l10n/app_localizations.dart';

class TermsAndPrivacyText extends StatelessWidget {
  final VoidCallback? onTermsPressed;
  final VoidCallback? onPrivacyPressed;
  final Color? regularTextColor;
  final Color? linkTextColor;
  final double? fontSize;
  final TextAlign? textAlign;

  const TermsAndPrivacyText({
    super.key,
    this.onTermsPressed,
    this.onPrivacyPressed,
    this.regularTextColor,
    this.linkTextColor,
    this.fontSize,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    // final sizes = Sizes.of(context);
    final effectiveFontSize =
        fontSize ??
        sizes!.responsiveFont(
          phoneVal: 14,
          tabletVal: 16,
        );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: AppLocalizations.of(context)!.agreement_prefix,
            // 'By Creating Account, I agree to SaveInGold ',
            style: TextStyle(
              color: regularTextColor ?? const Color(0xFFE5E1E1),
              fontSize: effectiveFontSize,
              fontFamily: GoogleFonts.roboto().fontFamily,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: AppLocalizations.of(context)!.terms_and_conditions,
            // 'Terms & Conditions',
            recognizer: TapGestureRecognizer()
              ..onTap =
                  onTermsPressed ??
                  () {
                    CommonService.openServiceUrl(
                      serviceUrl: "https://www.saveingold.ae/Terms&Conditions",
                    );
                  },
            style: TextStyle(
              color: linkTextColor ?? const Color(0xFFBBA473),
              fontSize: effectiveFontSize,
              fontFamily: GoogleFonts.roboto().fontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: AppLocalizations.of(context)!.agreement_and,
            // ' and ',
            style: TextStyle(
              color: regularTextColor ?? const Color(0xFFE5E1E1),
              fontSize: effectiveFontSize,
              fontFamily: GoogleFonts.roboto().fontFamily,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: AppLocalizations.of(context)!.privacy_policy,
            // 'Privacy Policy',
            recognizer: TapGestureRecognizer()
              ..onTap =
                  onPrivacyPressed ??
                  () {
                    CommonService.openServiceUrl(
                      serviceUrl: 'https://www.saveingold.ae/privacy-policy',
                    );
                  },
            style: TextStyle(
              color: linkTextColor ?? const Color(0xFFBBA473),
              fontSize: effectiveFontSize,
              fontFamily: GoogleFonts.roboto().fontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      textAlign: textAlign ?? TextAlign.center,
    );
  }
}