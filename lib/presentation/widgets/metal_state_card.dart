import 'package:flutter/material.dart';
import 'package:baghdad_bullion_house/data/models/history_model/GetMetalStatementsResponse.dart';

import '../../l10n/app_localizations.dart';
import '../../core/common_service.dart';
import 'package:baghdad_bullion_house/presentation/widgets/global_time.dart';

class MetalStatementCard extends StatefulWidget {
  final VoidCallback onTap;
  final MetalHistoryList statement;
  final bool rtl;

  const MetalStatementCard({
    super.key,
    required this.onTap,
    required this.statement,
    required this.rtl,
  });

  @override
  State<MetalStatementCard> createState() => _MetalStatementCardState();
}

class _MetalStatementCardState extends State<MetalStatementCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  String _formatIqd(num? value) {
    return CommonService.formatIQDForDisplay(value ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: ClipRect(
        child: Container(
          margin: const EdgeInsets.only(bottom: 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xff262929),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 🔑 CRITICAL
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTitle(context),
                  _buildStatusChip(context, widget.statement.status),
                ],
              ),

              const SizedBox(height: 12),
              _buildMainInfo(context),
              if (isExpanded) ...[
                const SizedBox(height: 12),

                // _buildDetailRow(
                //  widget.statement.paymentModel == "Invest" &&
                //         widget.statement.tradeType == "Sell"?
                //         AppLocalizations.of(context)!.goldDebit
                //         :AppLocalizations.of(context)!.goldCredit,
                //         widget.statement.paymentModel == "Invest"
                //         && widget.statement.tradeType == "Sell"?
                //         "${widget.statement.debit?.toStringAsFixed(3) ?? '0.00'}${AppLocalizations.of(context)!.metal_g}": "${widget.statement.credit?.toStringAsFixed(3) ?? '0.00'}${AppLocalizations.of(context)!.metal_g}",
                // ),
                _buildDetailRow(
                  (widget.statement.paymentModel == "Invest" &&
                              widget.statement.tradeType == "Sell") ||
                          (widget.statement.paymentModel == "BBH Wallet" &&
                              (widget.statement.debit ?? 0) > 0) ||
                          (widget.statement.paymentModel == "Gift Sent" &&
                              (widget.statement.debit ?? 0) > 0)
                      ? AppLocalizations.of(context)!.goldDebit
                      : AppLocalizations.of(context)!.goldCredit,

                  (widget.statement.paymentModel == "Invest" &&
                              widget.statement.tradeType == "Sell") ||
                          (widget.statement.paymentModel == "BBH Wallet" &&
                              (widget.statement.debit ?? 0) > 0) ||
                          (widget.statement.paymentModel == "Gift Sent" &&
                              (widget.statement.debit ?? 0) > 0)
                      ? "${CommonService.formatGramForDisplay(widget.statement.debit)}${AppLocalizations.of(context)!.metal_g}"
                      : "${CommonService.formatGramForDisplay(widget.statement.credit)}${AppLocalizations.of(context)!.metal_g}",
                ),
                _buildDetailRow(
                  AppLocalizations.of(context)!.balanceAfterTransaction,
                  "${CommonService.formatGramForDisplay(widget.statement.metalBalance)}${AppLocalizations.of(context)!.metal_g}",
                ),
                _buildDetailRow(
                  AppLocalizations.of(context)!.transactionType,
                  widget.rtl
                      ? (widget.statement.paymentModelInArabic ??
                            "")//AppLocalizations.of(context)!.not_available)
                      : (widget.statement.paymentModel ??
                            "")//AppLocalizations.of(context)!.not_available),
                ),
                _buildDetailRow(
                  AppLocalizations.of(context)!.grams_card_date_label,
                  DateTimeHelper.formatLocalDateTime(
                    widget.statement.date?.toString(),
                    context,
                  ),
                ),
                const Divider(color: Colors.white10, height: 24),
              ],
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => isExpanded = !isExpanded),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isExpanded ? l10n.see_less : l10n.see_details,
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
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Widget _buildTitle(BuildContext context) {
    String title = "";
    num quantity =
        widget.statement.paymentModel == "Invest" &&
            widget.statement.tradeType == "Sell" &&
            widget.statement.debit != 0
        ? (widget.statement.debit ?? 0.0)
        : (widget.statement.credit ?? 0.0);
    final bool isEsouqCheckout =
        (widget.statement.paymentModel == "BBH Wallet" ||
            widget.statement.paymentModel == "محفظة سيف إن جولد") &&
        (widget.statement.debit ?? 0) > 0;

    final bool isgiftSent =
        (widget.statement.paymentModel == "Gift Sent" ||
            widget.statement.paymentModel == "تم إرسال الهدية") &&
        (widget.statement.debit ?? 0) > 0;

    switch (widget.statement.paymentModel) {
      case "Advance Payment":
        title = AppLocalizations.of(context)!.metal_holder;
        break;
      case "Advance Settlement":
        title = AppLocalizations.of(context)!.metal_released;
        break;
      case "Gift Sent":
      case "Gift Received":
        title = AppLocalizations.of(context)!.gift;
        break;
      case "BBH Wallet":
        title = AppLocalizations.of(context)!.esouqPayment;
        break;
      case "Invest":
        title =
            widget.statement.paymentModel == "Invest" &&
                widget.statement.tradeType == "Sell"
            ? AppLocalizations.of(context)!.sold
            //"Sold"
            : AppLocalizations.of(context)!.purchased; //"Purchased";
    }

    final bool useDebit = isEsouqCheckout || isgiftSent;

    return Text(
      useDebit
          ? "$title: ${CommonService.formatGramForDisplay(widget.statement.debit)}${AppLocalizations.of(context)!.metal_g} ${AppLocalizations.of(context)!.gold}"
          : "$title: ${CommonService.formatGramForDisplay(quantity)}${AppLocalizations.of(context)!.metal_g} ${AppLocalizations.of(context)!.gold}",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  Widget _buildMainInfo(BuildContext context) {
    final bool isSell = widget.statement.tradeType == "Sell";

    final bool isEsouqCheckout =
        widget.statement.paymentModel == "BBH Wallet" &&
        (widget.statement.debit ?? 0) > 0;

    final bool isgiftSent =
        (widget.statement.paymentModel == "Gift Sent" ||
            widget.statement.paymentModel == "تم إرسال الهدية") &&
        (widget.statement.debit ?? 0) > 0;

    String label = isEsouqCheckout
        ? AppLocalizations.of(context)!
              .esouq_checkout_withdraw // 👈 add this key
        : isSell
        ? AppLocalizations.of(context)!.sold
        : AppLocalizations.of(context)!.history_bought_label;

    num? price = isSell
        ? widget.statement.sellingPrice
        : widget.statement.buyingPrice;

    final bool useSpecialRow = isEsouqCheckout || isgiftSent;

    final String finalLabel = isgiftSent
        ? widget.statement.paymentModel
              .toString() //AppLocalizations.of(context)!.gift
        : "$label";

    return useSpecialRow
        ? _buildEsouqRow(finalLabel, "")
        : _buildDetailRow(
            "$label ${AppLocalizations.of(context)!.at}",
            "${AppLocalizations.of(context)!.idq} ${_formatIqd(price)} ${AppLocalizations.of(context)!.g_}",
          );
  }
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  Widget _buildEsouqRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  Widget _buildGiftRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  Widget _buildStatusChip(BuildContext context, String? status) {
    final bool isOpened = status?.toLowerCase() == "opened";

    final displayText = isOpened
        ? AppLocalizations.of(context)!.grams_card_opened
        : (status == "Closed")
        ? AppLocalizations.of(context)!.status_closed
        : (status == "pending")
        ? AppLocalizations.of(context)!.pending
        : "";//.of(context)!.not_available;
    return displayText.isEmpty?SizedBox(): Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOpened ? const Color(0xFFBBA473) : Colors.white24,
        ),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: isOpened ? const Color(0xFFBBA473) : Colors.white54,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Widget _buildStatusChip(BuildContext context, String? status) {
  //   final bool isOpened = status?.toLowerCase() == "opened";

  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(
  //         color: isOpened ? const Color(0xFFBBA473) : Colors.white24,
  //       ),
  //     ),
  //     child: Text(
  //       status?.toUpperCase() ?? "N/A",
  //       style: TextStyle(
  //         color: isOpened ? const Color(0xFFBBA473) : Colors.white54,
  //         fontSize: 10,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //   );
  // }
}
