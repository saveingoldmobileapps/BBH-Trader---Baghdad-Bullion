import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saveingold_fzco/data/models/history_model/GetMetalStatementsResponse.dart';

import '../../l10n/app_localizations.dart';

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

  @override
  Widget build(BuildContext context) {
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
                _buildDetailRow(
                  AppLocalizations.of(context)!.goldCredit,
                  "${widget.statement.credit?.toStringAsFixed(2) ?? '0.00'}${AppLocalizations.of(context)!.metal_g}",
                ),
                _buildDetailRow(
                  AppLocalizations.of(context)!.balanceAfterTransaction,
                  "${widget.statement.metalBalance?.toStringAsFixed(2) ?? '0.00'}${AppLocalizations.of(context)!.metal_g}",
                ),
                _buildDetailRow(
                  AppLocalizations.of(context)!.transactionType,
                  widget.rtl
                      ? (widget.statement.paymentModelInArabic ?? 'N/A')
                      : (widget.statement.paymentModel ?? 'N/A'),
                ),
                _buildDetailRow(
                  AppLocalizations.of(context)!.grams_card_date_label,
                  widget.statement.date != null
                      ? DateFormat(
                          'EEEE, dd MMM yyyy, HH:mm',
                          Localizations.localeOf(context).languageCode,
                        ).format(
                          DateTime.parse(
                            widget.statement.date.toString(),
                          ).toLocal(),
                        )
                      : 'N/A',
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
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Widget _buildTitle(BuildContext context) {
    String title = "Trade";
    num quantity = widget.statement.credit != 0
        ? (widget.statement.credit ?? 0.0)
        : (widget.statement.debit ?? 0.0);

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
      case "SIG Wallet":
        title = AppLocalizations.of(context)!.esouqPayment;
        break;
    }

    return Text(
      "$title: ${quantity.toStringAsFixed(2)}${AppLocalizations.of(context)!.metal_g} Gold",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMainInfo(BuildContext context) {
    final bool isSell = widget.statement.tradeType == "Sell";
    String label = isSell
        ? AppLocalizations.of(context)!.sold
        : AppLocalizations.of(context)!.history_bought_label;

    num? price = isSell
        ? widget.statement.sellingPrice
        : widget.statement.buyingPrice;

    return _buildDetailRow(
      "$label at",
      "IQD ${price?.toStringAsFixed(2) ?? '0.00'}/g",
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
  Widget _buildStatusChip(BuildContext context, String? status) {
  final bool isOpened = status?.toLowerCase() == "opened";

  final displayText = isOpened
      ? AppLocalizations.of(context)!.grams_card_opened//"FILLED"
      : (status?.toUpperCase() ?? "N/A");

  return Container(
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
