import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/models/withdrawal_models/GetAllWithdrawalFundsResponse.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';

import '../../main.dart';

class WithdrawalFundCard extends StatelessWidget {
  final KAllWithdraws kAllWithdraw;
  final rtl;

  const WithdrawalFundCard({
    required this.rtl,
    super.key,
    required this.kAllWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    // // Convert from UTC to local time
    DateTime parsedDate = DateTime.parse("${kAllWithdraw.createdAt}").toLocal();
 
  final String localeCode = Localizations.localeOf(context).languageCode;
  String formattedDate = DateFormat(
    'EEE, dd MMM yyyy, HH:mm',
    localeCode == 'ar' ? 'ar' : 'en',
  ).format(parsedDate);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: Color(0xFF333333),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GetGenericText(
                    text: AppLocalizations.of(context)!.amount,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey3Color,
                  ),
                  GetGenericText(
                    text:
                        "${AppLocalizations.of(context)!.aed} ${kAllWithdraw.amount}",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey5Color,
                  ),
                ],
              ),
              statusCard(kAllWithdraw.status.toString()),
            ],
          ),
          ConstPadding.sizeBoxWithHeight(height: 4),
          rtl?
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GetGenericText(
                text: AppLocalizations.of(context)!.bank_name,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.grey3Color,
              ),

              GetGenericText(
                text: "${kAllWithdraw.bankName}",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
              ConstPadding.sizeBoxWithHeight(height: 4),
              GetGenericText(
                text: AppLocalizations.of(context)!.beneficiary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.grey3Color,
              ),
              GetGenericText(
                text: "${kAllWithdraw.beneficiaryName}",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
              ConstPadding.sizeBoxWithHeight(height: 4),
              GetGenericText(
                text: AppLocalizations.of(context)!.dep_label_iban,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.grey3Color,
              ),
              GetGenericText(
                text: "${kAllWithdraw.iban}",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
            ],
          ).getAlignRight():
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GetGenericText(
                text: AppLocalizations.of(context)!.bank_name,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.grey3Color,
              ),

              GetGenericText(
                text: "${kAllWithdraw.bankName}",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
              ConstPadding.sizeBoxWithHeight(height: 4),
              GetGenericText(
                text: AppLocalizations.of(context)!.beneficiary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.grey3Color,
              ),
              GetGenericText(
                text: "${kAllWithdraw.beneficiaryName}",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
              ConstPadding.sizeBoxWithHeight(height: 4),
              GetGenericText(
                text: AppLocalizations.of(context)!.dep_label_iban,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.grey3Color,
              ),
              GetGenericText(
                text: "${kAllWithdraw.iban}",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
            ],
          ).getAlign(),
          ConstPadding.sizeBoxWithHeight(height: 4),
          Row(
            children: [
              GetGenericText(
                text: formattedDate,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.grey4Color,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// status card
  Widget statusCard(String status) {
    switch (status.toLowerCase()) {
      case "rejected":
        return rejectionCard();
      case "approved":
        return acceptanceCard();
      case "cancelled":
        return canceledCard();
      default:
        return pendingCard();
    }
  }

  /// rejection card
  Widget rejectionCard() {
    return _statusContainer(
      text: AppLocalizations.of(navigatorKey.currentContext!)!.rejected,
      bgColor: AppColors.red900Color,
      textColor: AppColors.red800Color,
    );
  }

  Widget canceledCard() {
    return _statusContainer(
      text: AppLocalizations.of(navigatorKey.currentContext!)!.canceled,
      bgColor: AppColors.red900Color,
      textColor: AppColors.red800Color,
    );
  }

  /// acceptance card
  Widget acceptanceCard() {
    return _statusContainer(
      text: AppLocalizations.of(navigatorKey.currentContext!)!.approved,
      bgColor: Color(0xFF34C759),
      textColor: AppColors.green900Color,
    );
  }

  /// pending card
  Widget pendingCard() {
    return _statusContainer(
      text: AppLocalizations.of(navigatorKey.currentContext!)!.pending,
      bgColor: Color(0xFFE8B931),
      textColor: Color(0xFF11271C),
    );
  }

  /// status container
  Widget _statusContainer({
    required String text,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      width: sizes!.responsiveLandscapeWidth(
        phoneVal: 70,
        tabletVal: 90,
        tabletLandscapeVal: 100,
        isLandscape: sizes!.isLandscape(),
      ),
      height: sizes!.responsiveLandscapeHeight(
        phoneVal: 24,
        tabletVal: 34,
        tabletLandscapeVal: 40,
        isLandscape: sizes!.isLandscape(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: ShapeDecoration(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Center(
        child: GetGenericText(
          text: text,
          fontSize: sizes!.responsiveFont(
            phoneVal: 12,
            tabletVal: 14,
          ),
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
