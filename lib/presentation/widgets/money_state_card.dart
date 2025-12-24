import 'package:flutter/material.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';

import '../../data/models/history_model/NewMoneyApiResponseModel.dart';

class MoneyStatementCard extends StatelessWidget {
  final String title;
  final String action;
  final MoneyHistoryList data;
  final bool rtl;

  const MoneyStatementCard({
    super.key,
    required this.title,
    required this.data,
    required this.action,
    required this.rtl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sizes!.widthRatio * 361,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color(0xFF333333),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: Transaction ID
          rtl
              ? GetGenericText(
                  text: AppLocalizations.of(
                    context,
                  )!.transactionID, //"Transaction ID",
                  fontSize: sizes!.responsiveFont(phoneVal: 14, tabletVal: 16),
                  fontWeight: FontWeight.w500,
                  color: AppColors.whiteColor,
                ).getAlignRight()
              : GetGenericText(
                  text: AppLocalizations.of(
                    context,
                  )!.transactionID, //"Transaction ID",
                  fontSize: sizes!.responsiveFont(phoneVal: 14, tabletVal: 16),
                  fontWeight: FontWeight.w500,
                  color: AppColors.whiteColor,
                ).getAlign(),
          GetGenericText(
            text:
                data.transactionId ??
                AppLocalizations.of(context)!.not_available, //"N/A",
            fontSize: sizes!.responsiveFont(phoneVal: 20, tabletVal: 22),
            fontWeight: FontWeight.w600,
            color: AppColors.grey6Color,
          ),
          Divider(color: AppColors.grey2Color, height: 10),

          // Money Out and Debit with amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Directionality.of(context) == TextDirection.rtl
                  ? GetGenericText(
                      text: getLocalizedTransactionType(
                        context,
                        data.transactionType,
                      ),
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 16,
                        tabletVal: 18,
                      ),
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey6Color,
                    )
                  : GetGenericText(
                      text:
                          data.transactionType ??
                          AppLocalizations.of(context)!.not_available, //"N/A",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 16,
                        tabletVal: 18,
                      ),
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey6Color,
                    ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GetGenericText(
                    text: data.debit != null
                        ? AppLocalizations.of(context)!.debit
                        : AppLocalizations.of(
                            context,
                          )!.credit, //"Debit" : "Credit",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey6Color,
                  ),
                  GetGenericText(
                    text: data.credit != null
                        ? "${AppLocalizations.of(context)!.aed_currency} ${double.tryParse(data.credit.toString())?.toStringAsFixed(2) ?? '0.0'}"
                        : "${AppLocalizations.of(context)!.aed_currency} ${double.tryParse(data.debit.toString())?.toStringAsFixed(2) ?? '0.0'}",
                    // ? "AED ${double.tryParse(data.credit.toString())?.toStringAsFixed(2) ?? '0.0'}"
                    // : "AED ${double.tryParse(data.debit.toString())?.toStringAsFixed(2) ?? '0.0'}",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                    fontWeight: FontWeight.w400,
                    color: AppColors.whiteColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Transaction Method
          // _buildLabelValueRow(
          //   label: AppLocalizations.of(
          //     context,
          //   )!.transactionMethod, //"Transaction Method",
          //   value: data.paymentModel ?? "",
          // ),
          _buildLabelValueRow(
            label: AppLocalizations.of(context)!.transactionMethod,
            value: Directionality.of(context) == TextDirection.rtl
                ? (data.paymentModelInArabic != null &&
                          data.paymentModelInArabic!.isNotEmpty
                      ? data.paymentModelInArabic!
                      : data.paymentModel ?? "")
                : (data.paymentModel ?? ""),
          ),

          const SizedBox(height: 10),

          // Date & Time
          _buildLabelValueRow(
            label: AppLocalizations.of(context)!.dateTime, //"Date & Time",
            value: CommonService.formatDateTime(context, data.date!),
          ),
          const SizedBox(height: 10),

          // Balance After Transaction
          _buildLabelValueRow(
            label: AppLocalizations.of(
              context,
            )!.balanceAfterTransaction, //"Balance After Transaction",
            value:
                "${AppLocalizations.of(context)!.aed_currency} ${double.tryParse(data.moneyBalance.toString())?.toStringAsFixed(2) ?? ''}",
            // "AED ${double.tryParse(data.moneyBalance.toString())?.toStringAsFixed(2) ?? ''}",
          ),
        ],
      ),
    );
  }

  Widget _buildLabelValueRow({
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GetGenericText(
          text: label,
          fontSize: sizes!.responsiveFont(phoneVal: 12, tabletVal: 14),
          fontWeight: FontWeight.w400,
          color: AppColors.grey3Color,
        ),
        GetGenericText(
          text: value,
          fontSize: sizes!.responsiveFont(phoneVal: 14, tabletVal: 16),
          fontWeight: FontWeight.w500,
          color: AppColors.whiteColor,
        ),
      ],
    );
  }

  String getLocalizedTransactionType(BuildContext context, String? type) {
    if (type == null) return AppLocalizations.of(context)!.not_available;

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    if (!isRtl) return type; // return English as is for LTR

    switch (type) {
      case "CreditIn":
      case "Credit In":
        return "إضافة رصيد";

      case "Money in":
        return "إيداع";

      case "Money out":
        return "سحب";

      case "CreditOut":
      case "Credit Out":
        return "خصم رصيد";
      case "Deposit":
        return "إيداع";
      case "Withdraw":
        return "سحب";
      case "Adjustment":
        return "تعديل";
      case "LoanCreditOut":
      case "Loan Credit Out":
        return "سحب قرض";
      case "Cashback":
        return "استرداد نقدي";
      case "Referral Cashback":
        return "استرداد نقدي للإحالة";
      default:
        return AppLocalizations.of(context)!.not_available; // fallback
    }
  }
}
