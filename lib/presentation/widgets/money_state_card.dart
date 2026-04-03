import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';

import '../../data/models/history_model/NewMoneyApiResponseModel.dart';

class MoneyStatementCard extends StatefulWidget {
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
  State<MoneyStatementCard> createState() => _MoneyStatementCardState();
}

class _MoneyStatementCardState extends State<MoneyStatementCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final item = widget.data;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: sizes!.widthRatio * 361,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xff262929), // Transparent dark card from UI
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Prevents occupying extra space
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Transaction Type and Credit/Debit Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.rtl
                    ? getLocalizedTransactionType(context, item.transactionType)
                    : (item.transactionType ?? l10n.not_available),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.debit != null ? l10n.debit : l10n.credit,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    item.credit != null
                        ? "${l10n.idq_currency} ${double.tryParse(item.credit.toString())?.toStringAsFixed(2) ?? '0.00'}"
                        : "${l10n.idq_currency} ${double.tryParse(item.debit.toString())?.toStringAsFixed(2) ?? '0.00'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // See Details Toggle
          const SizedBox(height: 12),

          // Expandable Content logic
          if (isExpanded) ...[
            const Divider(color: Colors.white10, height: 24),
            _buildDetailRow("ID", item.transactionId ?? l10n.not_available),
            _buildDetailRow(
              l10n.transactionMethod,
              widget.rtl
                  ? (item.paymentModelInArabic?.isNotEmpty == true
                        ? item.paymentModelInArabic!
                        : item.paymentModel ?? "")
                  : (item.paymentModel ?? ""),
            ),
            _buildDetailRow(
              l10n.dateTime,
              CommonService.formatDateTime(context, item.date!),
            ),
            _buildDetailRow(
              l10n.balanceAfterTransaction,
              "${l10n.idq_currency} ${double.tryParse(item.moneyBalance.toString())?.toStringAsFixed(2) ?? '0.00'}",
            ),
            const SizedBox(height: 12),
          ],

          // Expand/Collapse Button (Matches Screenshot)
          Center(
            child: GestureDetector(
              onTap: () => setState(() => isExpanded = !isExpanded),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isExpanded ? "See Less" : "See Details",
                    style: const TextStyle(
                      color: Color(0xFFBBA473),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFFBBA473),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String getLocalizedTransactionType(BuildContext context, String? type) {
    if (type == null) return AppLocalizations.of(context)!.not_available;
    final isRtl = Directionality.of(context) == TextDirection.RTL;
    if (!isRtl) return type;

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
        return AppLocalizations.of(context)!.not_available;
    }
  }

}
