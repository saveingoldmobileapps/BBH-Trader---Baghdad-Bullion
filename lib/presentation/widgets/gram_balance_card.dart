import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/models/gram_balance/GramApiResponseModel.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';

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

class _GramBalanceCardState extends ConsumerState<GramBalanceCard> {
  /// get price
  String getPrice({required Payload gramList}) {
    if (gramList.tradeType == 'Buy') {
      final price = gramList.buyAtPrice ?? gramList.buyingPrice;
      if (price == null) {
        return '';
      }
      return price.toStringAsFixed(2);
    } else {
      final price = gramList.sellAtProfit ?? gramList.sellingPrice;
      if (price == null) {
        return '';
      }
      return price.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goldPriceState = ref.watch(goldPriceProvider);
    final isOpenedTrade = widget.gramList.tradeStatus == "Opened";
    final isTakeProfitTrade =
        widget.gramList.tradeType == "Sell" &&
        widget.gramList.tradeStatus == "Pending";

    // Calculate PnL only when all data is available
    // num? pnl;
    // if (isOpenedTrade && goldPriceState.hasValue) {
    //   pnl = CommonService.calculateLossOrProfit(
    //     buyingPrice: widget.gramList.buyingPrice ?? 0,
    //     livePrice: goldPriceState.value!.oneGramSellingPriceInAED,
    //     tradeMetalFactor: widget.gramList.tradeMetal ?? 0,
    //   );
    // }
    num? pnl;
    if ((isOpenedTrade || isTakeProfitTrade) && goldPriceState.hasValue) {
      pnl = CommonService.calculateLossOrProfit(
        buyingPrice: widget.gramList.buyingPrice ?? 0,
        livePrice: goldPriceState.value!.oneGramSellingPriceInAED,
        tradeMetalFactor: widget.gramList.tradeMetal ?? 0,
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: sizes!.widthRatio * 361,
        // height: sizes!.heightRatio * 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF333333),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.gramList.tradeType == 'Sell' &&
                widget.gramList.tradeStatus == "Pending")
              widget.rtl
                  ? GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.deal_take_profit, //"Take Profit"
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 12,
                        tabletVal: 14,
                      ),
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey5Color,
                    ).getAlignRight()
                  : GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.deal_take_profit, //"Take Profit",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 12,
                        tabletVal: 14,
                      ),
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey5Color,
                    ).getAlign()
            else if (widget.gramList.tradeCategory == 'Gift' &&
                widget.gramList.tradeStatus == "Opened")
              widget.rtl
                  ? GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.gram_gift_received, //"Gift Recieved",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 12,
                        tabletVal: 14,
                      ),
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey5Color,
                    ).getAlignRight()
                  : GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.gram_gift_received, //"Gift Recieved",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 12,
                        tabletVal: 14,
                      ),
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey5Color,
                    ).getAlign()
            else if (widget.gramList.tradeStatus != "Opened")
              widget.rtl
                  ? GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.gram_buy_at_price, // "Buy at Price Order",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 12,
                        tabletVal: 14,
                      ),
                      //16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey5Color,
                    ).getAlignRight()
                  : GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.gram_buy_at_price, //"Buy at Price Order",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 12,
                        tabletVal: 14,
                      ),
                      //16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey5Color,
                    ).getAlign(),
            ConstPadding.sizeBoxWithHeight(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GetGenericText(
                  text:
                      // AppLocalizations.of(context)!.trade_order_message(
                      //   tradeType,
                      //   grams,
                      //   price,
                      // ),
                      "${widget.gramList.tradeType == 'Buy' ? '${AppLocalizations.of(context)!.gram_buy_word}' : '${AppLocalizations.of(context)!.gram_sell_word}'} ${widget.gramList.tradeMetal!.toStringAsFixed(2)}${AppLocalizations.of(context)!.g_Gold} @${getPrice(gramList: widget.gramList)}",

                  //"${widget.gramList.tradeType == 'Buy' ? 'Buy' : 'Sell'} ${widget.gramList.tradeMetal!.toStringAsFixed(2)}g Gold @${getPrice(gramList: widget.gramList)}",
                  fontSize: sizes!.responsiveFont(
                    phoneVal: 16,
                    tabletVal: 18,
                  ),
                  //16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey5Color,
                ),
                const Spacer(),

                // Show PnL only for opened trades and when gold price is available
                // if (isOpenedTrade && pnl != null)
                if ((isOpenedTrade || isTakeProfitTrade) && pnl != null)
                  widget.rtl
                      ? Row(
                          children: [
                            GetGenericText(
                              text:
                                  "${AppLocalizations.of(context)!.aed_currency} ${pnl.abs().toStringAsFixed(2)}",
                              //text: "AED ${pnl.abs().toStringAsFixed(2)}",
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 12,
                                tabletVal: 14,
                              ),
                              fontWeight: FontWeight.w500,
                              color: pnl > 0
                                  ? AppColors.greenColor
                                  : AppColors.red900Color,
                            ),
                            SvgPicture.asset(
                              pnl > 0
                                  ? "assets/svg/grow_icon.svg"
                                  : "assets/svg/lost_icon.svg",
                              height: sizes!.responsiveHeight(
                                phoneVal: 18,
                                tabletVal: 32,
                              ),
                              //sizes!.heightRatio * (sizes!.isPhone ? 18 : 32),
                              width: sizes!.responsiveWidth(
                                phoneVal: 18,
                                tabletVal: 32,
                              ), //sizes!.widthRatio * (sizes!.isPhone ? 18 : 32),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            SvgPicture.asset(
                              pnl > 0
                                  ? "assets/svg/grow_icon.svg"
                                  : "assets/svg/lost_icon.svg",
                              height: sizes!.responsiveHeight(
                                phoneVal: 18,
                                tabletVal: 32,
                              ),
                              //sizes!.heightRatio * (sizes!.isPhone ? 18 : 32),
                              width: sizes!.responsiveWidth(
                                phoneVal: 18,
                                tabletVal: 32,
                              ), //sizes!.widthRatio * (sizes!.isPhone ? 18 : 32),
                            ),
                            GetGenericText(
                              text:
                                  "${AppLocalizations.of(context)!.aed_currency} ${pnl.abs().toStringAsFixed(2)}",
                              //text: "AED ${pnl.abs().toStringAsFixed(2)}",
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 12,
                                tabletVal: 14,
                              ),
                              fontWeight: FontWeight.w500,
                              color: pnl > 0
                                  ? AppColors.greenColor
                                  : AppColors.red900Color,
                            ),
                          ],
                        ),
                //],

                // if (widget.gramList.tradeStatus == "Opened" && showPnL) ...[
                //   /// Profit case
                //   Visibility(
                //     visible: pnl > 0,
                //     child: Row(
                //       children: [
                //         SvgPicture.asset(
                //           "assets/svg/grow_icon.svg",
                //           height:
                //               sizes!.heightRatio * (sizes!.isPhone ? 18 : 32),
                //           width: sizes!.widthRatio * (sizes!.isPhone ? 18 : 32),
                //         ),
                //         GetGenericText(
                //           text: "AED ${pnl.toStringAsFixed(2)}",
                //           fontSize: sizes!.responsiveFont(
                //             phoneVal: 12,
                //             tabletVal: 14,
                //           ),
                //           fontWeight: FontWeight.w500,
                //           color: AppColors.greenColor,
                //         ),
                //       ],
                //     ),
                //   ),
                //
                //   /// Loss case (includes zero)
                //   Visibility(
                //     visible: pnl <= 0,
                //     child: Row(
                //       children: [
                //         SvgPicture.asset(
                //           "assets/svg/lost_icon.svg",
                //           height:
                //               sizes!.heightRatio * (sizes!.isPhone ? 18 : 32),
                //           width: sizes!.widthRatio * (sizes!.isPhone ? 18 : 32),
                //         ),
                //         GetGenericText(
                //           text: "AED ${pnl.abs().toStringAsFixed(2)}",
                //           fontSize: sizes!.responsiveFont(
                //             phoneVal: 12,
                //             tabletVal: 14,
                //           ),
                //           fontWeight: FontWeight.w500,
                //           color: AppColors.red900Color,
                //         ),
                //       ],
                //     ),
                //   ),
                // ],
              ],
            ),
            ConstPadding.sizeBoxWithHeight(height: 6),
            widget.rtl
                ? GetGenericText(
                    text:
                        "${AppLocalizations.of(context)!.gram_invest_money} ${widget.gramList.tradeMoney?.toStringAsFixed(2) ?? '0.00'}",

                    //"Invest Money: AED ${widget.gramList.tradeMoney?.toStringAsFixed(2) ?? '0.00'}",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 12,
                      tabletVal: 14,
                    ),
                    //14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey4Color,
                  ).getAlignRight()
                : GetGenericText(
                    text:
                        "${AppLocalizations.of(context)!.gram_invest_money} ${widget.gramList.tradeMoney?.toStringAsFixed(2) ?? '0.00'}",

                    // "Invest Money: AED ${widget.gramList.tradeMoney?.toStringAsFixed(2) ?? '0.00'}",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 14,
                      tabletVal: 16,
                    ),
                    //14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey4Color,
                  ).getAlign(),
            ConstPadding.sizeBoxWithHeight(height: 6),
            widget.rtl
                ? GetGenericText(
                    text:
                        "${AppLocalizations.of(context)!.grams_card_invest_status} ${_getLocalizedTradeStatus(widget.gramList.tradeStatus)}",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 14,
                      tabletVal: 16,
                    ),
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey4Color,
                  ).getAlignRight()
                // GetGenericText(
                //     text:
                //         "${AppLocalizations.of(context)!.grams_card_invest_status} ${widget.gramList.tradeStatus}",
                //     //text: "Invest Status: ${widget.gramList.tradeStatus}",
                //     fontSize: sizes!.responsiveFont(
                //       phoneVal: 14,
                //       tabletVal: 16,
                //     ),
                //     fontWeight: FontWeight.w500,
                //     color: AppColors.grey4Color,
                //   ).getAlignRight()
                : GetGenericText(
                    text:
                        "${AppLocalizations.of(context)!.grams_card_invest_status} ${widget.gramList.tradeStatus}",
                    // text: "Invest Status: ${widget.gramList.tradeStatus}",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 14,
                      tabletVal: 16,
                    ),
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey4Color,
                  ).getAlign(),
            ConstPadding.sizeBoxWithHeight(height: 6),
            widget.rtl
                ? GetGenericText(
                    text:
                        "${AppLocalizations.of(context)!.grams_card_date_label} ${widget.gramList.createdAt != null ? DateFormat('EEEE, dd MMM yyyy, HH:mm', Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'en').format(DateTime.parse(widget.gramList.createdAt.toString()).toLocal()) : 'N/A'}",
                    //  "${AppLocalizations.of(context)!.grams_card_date_label} ${widget.gramList.createdAt != null ? DateFormat('EEE, dd MMM yyyy, HH:mm').format(DateTime.parse(widget.gramList.createdAt.toString()).toLocal()) : 'N/A'}",
                    //"Date: ${widget.gramList.createdAt != null ? DateFormat('EEE, dd MMM yyyy, HH:mm').format(DateTime.parse(widget.gramList.createdAt.toString()).toLocal()) : 'N/A'}",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 12,
                      tabletVal: 14,
                    ),
                    //14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey4Color,
                  ).getAlignRight()
                : GetGenericText(
                    text:
                        "${AppLocalizations.of(context)!.grams_card_date_label} ${widget.gramList.createdAt != null ? DateFormat('EEEE, dd MMM yyyy, HH:mm', Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'en').format(DateTime.parse(widget.gramList.createdAt.toString()).toLocal()) : 'N/A'}",
                    // "${AppLocalizations.of(context)!.grams_card_date_label} ${widget.gramList.createdAt != null ? DateFormat('EEE, dd MMM yyyy, HH:mm').format(DateTime.parse(widget.gramList.createdAt.toString()).toLocal()) : 'N/A'}",
                    //"Date: ${widget.gramList.createdAt != null ? DateFormat('EEE, dd MMM yyyy, HH:mm').format(DateTime.parse(widget.gramList.createdAt.toString()).toLocal()) : 'N/A'}",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 12,
                      tabletVal: 14,
                      //
                    ),
                    //14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey4Color,
                  ).getAlign(),


            ConstPadding.sizeBoxWithHeight(height: 6),
            widget.rtl
                ?widget.gramList.barNumber!= null? GetGenericText(
                    text: "${AppLocalizations.of(context)!.gram_bar_nmbr} ${widget.gramList.barNumber.toString()}",
                    color: AppColors.goldLightColor,
                        //"${AppLocalizations.of(context)!.grams_card_date_label} ${widget.gramList.createdAt != null ? DateFormat('EEEE, dd MMM yyyy, HH:mm', Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'en').format(DateTime.parse(widget.gramList.createdAt.toString()).toLocal()) : 'N/A'}",
                    //  "${AppLocalizations.of(context)!.grams_card_date_label} ${widget.gramList.createdAt != null ? DateFormat('EEE, dd MMM yyyy, HH:mm').format(DateTime.parse(widget.gramList.createdAt.toString()).toLocal()) : 'N/A'}",
                    //"Date: ${widget.gramList.createdAt != null ? DateFormat('EEE, dd MMM yyyy, HH:mm').format(DateTime.parse(widget.gramList.createdAt.toString()).toLocal()) : 'N/A'}",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 12,
                      tabletVal: 14,
                    ),
                    //14,
                    fontWeight: FontWeight.w500,
                  ).getAlignRight(): SizedBox.shrink()
                :widget.gramList.barNumber!= null? GetGenericText(
                    text: "${AppLocalizations.of(context)!.gram_bar_nmbr} ${widget.gramList.barNumber.toString()}",
                    color: AppColors.goldLightColor,
                    
                        //"${AppLocalizations.of(context)!.grams_card_date_label} ${widget.gramList.createdAt != null ? DateFormat('EEEE, dd MMM yyyy, HH:mm', Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'en').format(DateTime.parse(widget.gramList.createdAt.toString()).toLocal()) : 'N/A'}",
                    // "${AppLocalizations.of(context)!.grams_card_date_label} ${widget.gramList.createdAt != null ? DateFormat('EEE, dd MMM yyyy, HH:mm').format(DateTime.parse(widget.gramList.createdAt.toString()).toLocal()) : 'N/A'}",
                    //"Date: ${widget.gramList.createdAt != null ? DateFormat('EEE, dd MMM yyyy, HH:mm').format(DateTime.parse(widget.gramList.createdAt.toString()).toLocal()) : 'N/A'}",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 12,
                      tabletVal: 14,
                      
                      //
                    ),
                    //14,
                    fontWeight: FontWeight.w500,
                  ).getAlign()
                  : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  String _getLocalizedTradeStatus(String? status) {
    if (status == null) return "";

    switch (status.toLowerCase()) {
      case "pending":
        return "قيد الانتظار";
      case "opened":
        return "مفتوح";
      default:
        return status;
    }
  }
}
