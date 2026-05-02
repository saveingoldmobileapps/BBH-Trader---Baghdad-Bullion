import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/data/models/gram_balance/GramApiResponseModel.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';

import '../sharedProviders/providers/sseGoldPriceProvider/sse_gold_price_provider.dart';

class GramBalanceCard extends ConsumerStatefulWidget {
  final VoidCallback onTap;
  final Payload gramList;
  final bool rtl;

  const GramBalanceCard({
    super.key,
    required this.gramList,
    required this.onTap,
    required this.rtl,
  });

  @override
  ConsumerState createState() => _GramBalanceCardState();
}
 String _formatIqd(num? value) {
    return CommonService.formatIQDForDisplay(value ?? 0);
  }

class _GramBalanceCardState extends ConsumerState<GramBalanceCard> {
  String getPrice({required Payload gramList}) {
    if (gramList.tradeType == 'Buy') {
      final price = gramList.buyAtPrice ?? gramList.buyingPrice;
      return price != null ? CommonService.formatIqdCurrency(price) : '';
    } else {
      final price = gramList.sellAtProfit ?? gramList.sellingPrice;
      return price != null ? CommonService.formatIqdCurrency(price) : '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final goldPriceState = ref.watch(goldPriceProvider);
    final l10n = AppLocalizations.of(context)!;
    final item = widget.gramList;

    final isOpenedTrade = item.tradeStatus == "Opened";
    final isTakeProfitTrade =
        item.tradeType == "Sell" && item.tradeStatus == "Pending";

    // PnL Logic preserved from your code
    num? pnl;
    if ((isOpenedTrade || isTakeProfitTrade) && goldPriceState.hasValue) {
      pnl = CommonService.calculateLossOrProfit(
        buyingPrice: item.buyingPrice ?? 0,
        livePrice: goldPriceState.value!.oneGramSellingPriceInIQD,
        tradeMetalFactor: item.tradeMetal ?? 0,
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            // Title and Profit Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${CommonService.formatGramForDisplay(item.tradeMetal)} ${AppLocalizations.of(context)!.g_Gold}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (pnl != null)

  // Row(
  //   children: [
  //     Icon(
  //       pnl >= 0 ? Icons.north_east : Icons.south_east,
  //       color: pnl >= 0 ? Colors.green : Colors.red,
  //       size: 16,
  //     ),
  //     const SizedBox(width: 4),
  //     Text(
  //       "${pnl >= 0 ? '+' : '-'}${CommonService.formatIqdCurrency(pnl.abs())} "
  //       "${pnl >= 0 
  //           ? AppLocalizations.of(context)!.metal_profit 
  //           : "Loss"
  //           }",
  //       style: TextStyle(
  //         color: pnl >= 0 ? Colors.green : Colors.red,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //   ],
  // ),
  widget.rtl?
    Row(
  children: [
    Icon(
      pnl >= 0 ? Icons.north_east : Icons.south_east,
      color: pnl >= 0 ? Colors.green : Colors.red,
      size: 16,
    ),
    const SizedBox(width: 4),
    Text(
      // pnl >= 0 
      //     ? widget.rtl?"${CommonService.formatIqdCurrency(pnl)}+ ${AppLocalizations.of(context)!.metal_profit}": "+ ${CommonService.formatIqdCurrency(pnl)} ${AppLocalizations.of(context)!.metal_profit}"
      //     : "${CommonService.formatIqdCurrency(pnl.abs())}- ${AppLocalizations.of(context)!.metal_loss}",
     pnl >= 0
          ?"${CommonService.formatIqdCurrency(pnl)}+ ${AppLocalizations.of(context)!.metal_profit}"
          : "${CommonService.formatIqdCurrency(pnl.abs())}- ${AppLocalizations.of(context)!.metal_loss}",
      style: TextStyle(
        color: pnl >= 0 ? Colors.green : Colors.red,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
):
  Row(
  children: [
    Icon(
      pnl >= 0 ? Icons.north_east : Icons.south_east,
      color: pnl >= 0 ? Colors.green : Colors.red,
      size: 16,
    ),
    const SizedBox(width: 4),
    Text(
      // pnl >= 0 
      //     ? widget.rtl?"${CommonService.formatIqdCurrency(pnl)}+ ${AppLocalizations.of(context)!.metal_profit}": "+ ${CommonService.formatIqdCurrency(pnl)} ${AppLocalizations.of(context)!.metal_profit}"
      //     : "${CommonService.formatIqdCurrency(pnl.abs())}- ${AppLocalizations.of(context)!.metal_loss}",
     pnl >= 0
          ?"+${CommonService.formatIqdCurrency(pnl)} ${AppLocalizations.of(context)!.metal_profit}"
          : "-${CommonService.formatIqdCurrency(pnl.abs())} ${AppLocalizations.of(context)!.metal_loss}",
      style: TextStyle(
        color: pnl >= 0 ? Colors.green : Colors.red,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
),
                  // Row(
                  //   children: [
                  //     Icon(
                  //       pnl >= 0 ? Icons.north_east : Icons.south_east,
                  //       color: pnl >= 0 ? Colors.green : Colors.red,
                  //       size: 16,
                  //     ),
                  //     const SizedBox(width: 4),
                  //     Text(
                        
                  //       "${CommonService.formatIqdCurrency(pnl.abs())} ${AppLocalizations.of(context)!.metal_profit}",
                  //       style: TextStyle(
                  //         color: pnl >= 0 ? Colors.green : Colors.red,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ],
                  // ),
              ],
            ),
            const SizedBox(height: 16),

            // Detail Rows
            _detailRow(
              l10n.gram_buy_word == "Buy" ? "Bought @" : "تم الشراء @",
              "${AppLocalizations.of(context)!.idq} ${_formatIqd(item.buyingPrice) ?? '0.00'}",
            ),
            const SizedBox(height: 10),
            _detailRow(
              AppLocalizations.of(context)!.gram_current_price,
              //"Current price",
              "${AppLocalizations.of(context)!.idq} ${_formatIqd(goldPriceState.value?.oneGramSellingPriceInIQD) ?? '0.00'}",
            ),
            const SizedBox(height: 10),

            // Target/Money Row (Adapts if trade is target-based)
            if (item.buyAtPriceStatus == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _detailRow(
                  AppLocalizations.of(context)!.gram_target_price,
                  //"Target price",
                  "${AppLocalizations.of(context)!.idq} ${_formatIqd(item.buyAtPrice) ?? '0.00'}",
                ),
              ),

            // Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  AppLocalizations.of(context)!.gram_status,
                  //"Status",
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFBBA473).withOpacity(0.5),
                    ),
                  ),
                  child: 
                  Text(
                    (item.tradeStatus == "Opened")
                        ? AppLocalizations.of(context)!.grams_card_opened
                        : (item.tradeStatus == "Pending")
          ? AppLocalizations.of(context)!.pending: "",
          //(item.tradeStatus ?? ""),
  //                 Text(
  // (item.tradeStatus == "opened")
  //     ? AppLocalizations.of(context)!.grams_card_opened
  //     : (item.tradeStatus == "Pending")
  //         ? AppLocalizations.of(context)!.pending
  //         : (item.tradeStatus == "closed")
  //             ? AppLocalizations.of(context)!.status_closed
  //             : AppLocalizations.of(context)!.not_available,



                    style: const TextStyle(
                      color: Color(0xFFBBA473),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Text(
                  //   item.tradeStatus ?? "Opened",
                  //   style: const TextStyle(
                  //     color: Color(0xFFBBA473),
                  //     fontSize: 12,
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  // ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
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
    );
  }
}
