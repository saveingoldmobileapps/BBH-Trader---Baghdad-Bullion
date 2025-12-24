import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';

class AccountWarning extends StatelessWidget {
  final String kycStatus;
  final VoidCallback onTap;

  const AccountWarning({
    required this.kycStatus,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              "assets/svg/alert_icon.svg",
            ),
            ConstPadding.sizeBoxWithWidth(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GetGenericText(
                  //   text:
                  //       "Please verify your $kycStatus to get access to all the features.",
                  //   fontSize: sizes!.isPhone ? 12 : 16,
                  //   fontWeight: sizes!.isPhone
                  //       ? FontWeight.w400
                  //       : FontWeight.w600,
                  //   color: AppColors.whiteColor,
                  //   isInter: true,
                  // ),
                  GetGenericText(
                    text: AppLocalizations.of(
                      context,
                    )!.account_warning(kycStatus),
                    fontSize: sizes!.isPhone ? 12 : 16,
                    fontWeight: sizes!.isPhone
                        ? FontWeight.w400
                        : FontWeight.w600,
                    color: AppColors.whiteColor,
                    isInter: true,
                  ),

                  ConstPadding.sizeBoxWithHeight(height: 4),
                  GetGenericText(
                    text: AppLocalizations.of(
                      context,
                    )!.verify_account, //"Verify Account",
                    // text: kycStatus == "custom Kyc"
                    //     ? "See More"
                    //     : "Verify Account",
                    fontSize: sizes!.isPhone ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGold500,
                    isInter: true,
                    isUnderline: true,
                  ),
                ],
              ),
            ),
          ],
        ).get6VerticalPadding(),
      ),
    );
  }
}
