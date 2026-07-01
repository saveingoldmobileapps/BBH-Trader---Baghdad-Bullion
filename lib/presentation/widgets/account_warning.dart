import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';

class AccountWarning extends StatelessWidget {
  final String kycStatus;
  final VoidCallback onTap;
  final String? warningMessage;
  final String? actionText;

  const AccountWarning({
    required this.kycStatus,
    required this.onTap,
    this.warningMessage,
    this.actionText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xffE04c4E), 
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12), 
        ),
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
                  GetGenericText(
                    text: warningMessage ??
                        AppLocalizations.of(
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
                    text: actionText ??
                        AppLocalizations.of(
                          context,
                        )!.verify_account,
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
