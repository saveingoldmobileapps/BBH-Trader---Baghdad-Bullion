import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/widgets/auto_scale_text.dart';

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

  /// Until the API returns grams on money statements, show a fixed placeholder.
  static const String _gramAmountPlaceholder = '50';

  String _formatIqd(num? value) {
    return CommonService.formatIqdCurrency(value ?? 0);
  }

  String _formatIraqDateTime(String? isoDate, BuildContext context) {
    if (isoDate == null || isoDate.isEmpty)
      return AppLocalizations.of(context)!.not_available;
    try {
      final parsed = DateTime.parse(isoDate);
      final iraqTime = parsed.toUtc().add(const Duration(hours: 3));
      final locale = Localizations.localeOf(context).languageCode == 'ar'
          ? 'ar_IQ'
          : 'en_IQ';
      return DateFormat('dd/MM/yyyy, HH:mm', locale).format(iraqTime);
    } catch (_) {
      return isoDate;
    }
  }

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
          // Full-width headline; when debit/credit exist, IQD appears only in this line (no side column).
          SizedBox(
            width: double.infinity,
            child: AutoScaleText(
              text: _moneyHistoryHeadline(context),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              alignment: widget.rtl? Alignment.centerRight: Alignment.centerLeft,
              maxLines: item.credit != null || item.debit != null ? 6 : 4,
            ),
          ),

          // See Details Toggle
          const SizedBox(height: 12),

          // Expandable Content logic
          if (isExpanded) ...[
            const Divider(color: Colors.white10, height: 24),
            widget.rtl?
            _buildDetailRow("المعرّف", item.transactionId ?? l10n.not_available)
            :
            _buildDetailRow("ID", item.transactionId ?? l10n.not_available),
            // Add Transaction Type in both languages
            _buildDetailRow(
              widget.rtl ? "نوع المعاملة" : l10n.transactionType,
              getLocalizedTransactionType(context, item.transactionType),
            ),
            _buildDetailRow(
              widget.rtl ? "طريقة الدفع" : l10n.transactionMethod,
              widget.rtl
                  ? (item.paymentModelInArabic?.isNotEmpty == true
                        ? item.paymentModelInArabic!
                        : item.paymentModel ?? "")
                  : (item.paymentModel ?? ""),
            ),
            // Show debit or credit amount if available
            if (item.debit != null && item.debit! > 0)
              _buildDetailRow(
                widget.rtl ? "المبلغ (مدين)" : "Debit Amount",
                "${l10n.idq_currency} ${_formatIqd(double.tryParse(item.debit.toString()) ?? 0)}",
              ),
            if (item.credit != null && item.credit! > 0)
              _buildDetailRow(
                widget.rtl ? "المبلغ (دائن)" : "Credit Amount",
                "${l10n.idq_currency} ${_formatIqd(double.tryParse(item.credit.toString()) ?? 0)}",
              ),
            // Show grams if available
            if (item.grams != null && item.grams! > 0)
              _buildDetailRow(
                widget.rtl ? "الجرامات" : "Grams",
                "${item.grams} ${widget.rtl ? "جرام" : "gram"}",
              ),
            _buildDetailRow(
              widget.rtl ? "التاريخ والوقت" : l10n.dateTime,
              _formatIraqDateTime(item.date, context),
            ),
            _buildDetailRow(
              widget.rtl ? "الرصيد بعد المعاملة" : l10n.balanceAfterTransaction,
              "${l10n.idq_currency} ${_formatIqd(double.tryParse(item.moneyBalance.toString()) ?? 0)}",
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
                    isExpanded 
                        ? (widget.rtl ? "إظهار أقل" : l10n.see_less)
                        : (widget.rtl ? "تفاصيل أكثر" : l10n.see_details),
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

  /// Debit → purchase line; credit → sale/proceeds line; IQD from debit or credit amount.
  // String _moneyHistoryHeadline(BuildContext context) {
  //   final l10n = AppLocalizations.of(context)!;
  //   final item = widget.data;
  //   final isRtl = widget.rtl;
    
  //   // Get localized transaction type
  //   String transactionTypeText = getLocalizedTransactionType(context, item.transactionType);
    
  //   // Handle debit (purchase/withdrawal)
  //   if (item.debit != null && item.debit! > 0) {
  //     final iqd = _formatIqd(double.tryParse(item.debit.toString()) ?? 0);
      
  //     if (isRtl) {
  //       return "$transactionTypeText\n$iqd د.ع (مدين)";
  //     } else {
  //       return "$transactionTypeText: $iqd IQD (Debit)";
  //     }
  //   }
    
  //   // Handle credit (sale/deposit)
  //   if (item.credit != null && item.credit! > 0) {
  //     final iqd = _formatIqd(double.tryParse(item.credit.toString()) ?? 0);
      
  //     if (isRtl) {
  //       return "$transactionTypeText $iqd د.ع (دائن)";
  //     } else {
  //       return "$transactionTypeText: $iqd IQD (Credit)";
  //     }
  //   }
    
  //   // Fallback: just show transaction type
  //   return transactionTypeText;
  // }
  String _moneyHistoryHeadline(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final item = widget.data;
  final isRtl = widget.rtl;

  String transactionTypeText =
      getLocalizedTransactionType(context, item.transactionType);

  final isSpecialModel =
      item.paymentModel == "Invest" ;

  final esouqCheckout = item.paymentModel  == "BBH Wallet";
  /// Extract grams (adjust field if your model differs)
  final grams = item.grams ?? 0; // <-- update if needed

  /// Handle DEBIT (Buy / Withdrawal)
  if (item.debit != null && item.debit! > 0) {
    final iqd = _formatIqd(double.tryParse(item.debit.toString()) ?? 0);

    /// ✅ Special Case
    if (isSpecialModel) {
      if (isRtl) {
        return "شراء:\n$iqd د.ع لتغطية شراء $grams غرام من الذهب";
      } else {
        return "Buy:\nIQD $iqd covering the purchase of $grams gram(s) of gold";
      }
    }
    if (esouqCheckout) {
      if (isRtl) {
        return "الدفع عبر إي سوق:\n$iqd د.ع لتغطية شراء $grams غرام من الذهب";
      } else {
        return "Esouq Checkout:\nIQD $iqd covering the purchase of $grams gram(s) of gold";
      }
    }

    /// Default
    if (isRtl) {
      return "$transactionTypeText\n$iqd د.ع (مدين)";
    } else {
      return "$transactionTypeText: $iqd IQD (Debit)";
    }
  }

  /// Handle CREDIT (Sell / Deposit)
  if (item.credit != null && item.credit! > 0) {
    final iqd = _formatIqd(double.tryParse(item.credit.toString()) ?? 0);

    /// ✅ Special Case
    if (isSpecialModel) {
      if (isRtl) {
        return "بيع:\n$iqd د.ع عائدات بيع $grams غرام من الذهب";
      } else {
        return "Sell:\nIQD $iqd being proceeds from the sale of $grams gram(s) of gold";
      }
    }

    /// Default
    if (isRtl) {
      return "$transactionTypeText $iqd د.ع (دائن)";
    } else {
      return "$transactionTypeText: $iqd IQD (Credit)";
    }
  }

  /// Fallback
  return transactionTypeText;
}

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Fixed width for labels to ensure alignment
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String getLocalizedTransactionType(BuildContext context, String? type) {
    if (type == null) return AppLocalizations.of(context)!.not_available;
    final isRtl = widget.rtl;
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
      case "Covering the Purchase":
        return "تغطية الشراء";
      case "Proceeds from the Sale":
        return "عائدات البيع";
      case "Invest":
        return "استثمار";
      case "WithdrawInvest":
        return "سحب استثمار";
      case "Transfer":
        return "تحويل";
      case "Received":
        return "استلام";
      default:
        return type; // Return original if no mapping found
    }
  }
}