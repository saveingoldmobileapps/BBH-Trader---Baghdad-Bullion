import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/data/models/gram_balance/GramApiResponseModel.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/presentation/sharedProviders/providers/gram_provider/gram_provider.dart';
import 'package:baghdad_bullion_house/presentation/sharedProviders/providers/home_provider.dart';
import 'package:baghdad_bullion_house/presentation/sharedProviders/providers/trade_provider/trade_provider.dart';
import 'package:baghdad_bullion_house/presentation/widgets/global_time.dart';
import 'package:baghdad_bullion_house/presentation/widgets/input_formater.dart';
import 'package:baghdad_bullion_house/presentation/widgets/widget_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../sharedProviders/providers/sseGoldPriceProvider/sse_gold_price_provider.dart';
import '../../widgets/shimmers/shimmer_loader.dart';

class GramDealDetailScreen extends ConsumerStatefulWidget {
  final Payload gramData;

  const GramDealDetailScreen({
    super.key,
    required this.gramData,
  });

  @override
  ConsumerState createState() => _GramDealDetailScreenState();
}

class _GramDealDetailScreenState extends ConsumerState<GramDealDetailScreen> {
  bool isEdit = false;
  bool isCloseEdit = false;
  bool isTakeProfit = false;

  bool isEditPrice = false;
  bool isGramAmountPrice = false;

  final sellAtPriceController = TextEditingController();
  final gramAmountController = TextEditingController();
  final closeDealAmountGramController = TextEditingController();

  final _formTakeProfitKey = GlobalKey<FormState>();
  final _formCloseDealKey = GlobalKey<FormState>();

  final _formEditPriceKey = GlobalKey<FormState>();
  final _formEditAmountKey = GlobalKey<FormState>();

  final _focusAmountGramNode = FocusNode(); // Add FocusNode
  final _focusSellAtPriceNode = FocusNode(); // Add FocusNode

  // String _formatIraqGregorianDateTime(String? isoDate, BuildContext context) {
  //   if (isoDate == null || isoDate.isEmpty) return '-';
  //   try {
  //     final parsed = DateTime.parse(isoDate);
  //     final iraqTime = parsed.toUtc().add(const Duration(hours: 3));
  //     final locale = Localizations.localeOf(context).languageCode == 'ar'
  //         ? 'ar_IQ'
  //         : 'en_IQ';
  //     return DateFormat('dd/MM/yyyy, HH:mm', locale).format(iraqTime);
  //   } catch (_) {
  //     return isoDate;
  //   }
  // }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getHomeFeed();
    });

    super.initState();
  }

  Future<void> getHomeFeed() async {
    await ref
        .read(homeProvider.notifier)
        .getHomeFeed(
          context: context,
          showLoading: true,
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);

    // ref
    //     .read(homeProvider.notifier)
    //     .getHomeFeed(context: context, showLoading: true);
    // final updatedPayload = ref.read(homeProvider).getHomeFeedResponse.payload;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    sellAtPriceController.dispose();
    closeDealAmountGramController.dispose();
    _focusAmountGramNode.dispose();
    _focusSellAtPriceNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Refresh sizes on orientation change
    sizes!.refreshSize(context);
    //final mainStateWatchProvider = ref.watch(homeProvider);

    ///provider
    //final gramStateWatchProvider = ref.watch(gramProvider);
    final gramStateReadProvider = ref.read(gramProvider.notifier);
    // Keep autoDispose providers alive while this screen is mounted.
    ref.watch(tradeProvider);
    final homeState = ref.watch(homeProvider);
    final homeFeed = homeState.getHomeFeedResponse;

    /// trade state read provider
    final tradeStateReadProvider = ref.read(tradeProvider.notifier);

    final goldPriceStateWatchProvider = ref.watch(goldPriceProvider);
    final liveBuyGramIqd =
        goldPriceStateWatchProvider.value?.oneGramBuyingPriceInIQD ?? 0.0;
    final liveSellGramIqd =
        goldPriceStateWatchProvider.value?.oneGramSellingPriceInIQD ?? 0.0;
    final canPendingOrderUseLivePrice = widget.gramData.tradeType == "Sell"
        ? liveSellGramIqd > 0
        : liveBuyGramIqd > 0;
    final canUseLiveSellForDeal = liveSellGramIqd > 0;
    final isTakeProfitTrade =
        widget.gramData.tradeType == "Sell" &&
        widget.gramData.tradeStatus == "Pending";

    /// Calculate profit or loss
    num pnl = CommonService.calculateLossOrProfit(
      buyingPrice: widget.gramData.buyingPrice ?? 0,
      livePrice:
          goldPriceStateWatchProvider.value?.oneGramSellingPriceInIQD ?? 0.0,
      tradeMetalFactor: widget.gramData.tradeMetal ?? 0,
    );
    debugPrint("GramDealDetailScreenRebuild");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: GetGenericText(
          text: AppLocalizations.of(
            context,
          )!.dealDetails_title, //"Deal Details",
          fontSize: sizes!.responsiveFont(
            phoneVal: 20,
            tabletVal: 24,
          ), //20,
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
      ),
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        decoration: const BoxDecoration(
          color: AppColors.greyScale1000,
        ),
        child: SafeArea(
          child: homeFeed.payload == null
              ? Center(
                  child: ShimmerLoader(
                    loop: 5,
                  ),
                ).get20HorizontalPadding()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GetGenericText(
                            text: AppLocalizations.of(
                              context,
                            )!.deal_id_label, //"Deal ID",
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 16,
                              tabletVal: 18,
                            ), //16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.grey3Color,
                          ),
                          GetGenericText(
                            text: "${widget.gramData.dealId}",
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 24,
                              tabletVal: 26,
                            ), //24,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey5Color,
                          ),
                        ],
                      ),
                      ConstPadding.sizeBoxWithHeight(height: 24),

                      /// Trade Type
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GetGenericText(
                              text:
                                  "${widget.gramData.tradeType == "Sell" && widget.gramData.tradeStatus == "Pending"
                                      ? AppLocalizations.of(context)!.pending_sell
                                      : widget.gramData.tradeType == "Sell"
                                      ? AppLocalizations.of(context)!.sold
                                      : AppLocalizations.of(context)!.deal_buy_order} ${CommonService.formatGramForDisplay(widget.gramData.tradeMetal)} ${AppLocalizations.of(context)!.g_Gold}",
                              // "${widget.gramData.tradeType == "Sell" ? "Sold" : "Buy Order"} ${widget.gramData.tradeMetal!.toStringAsFixed(2)}g Gold",
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 15,
                                tabletVal: 20,
                              ), //20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey5Color,
                              lines: 4,
                            ),
                          ),
                          // Expanded(
                          //   child: GetGenericText(
                          //     text:
                          //         "${widget.gramData.tradeType == "Sell" ? AppLocalizations.of(context)!.sold : AppLocalizations.of(context)!.deal_buy_order} ${widget.gramData.tradeMetal!.toStringAsFixed(3)} ${AppLocalizations.of(context)!.g_Gold}",
                          //     // "${widget.gramData.tradeType == "Sell" ? "Sold" : "Buy Order"} ${widget.gramData.tradeMetal!.toStringAsFixed(2)}g Gold",
                          //     fontSize: sizes!.responsiveFont(
                          //       phoneVal: 20,
                          //       tabletVal: 24,
                          //     ), //20,
                          //     fontWeight: FontWeight.w700,
                          //     color: AppColors.grey5Color,
                          //     lines: 4,
                          //   ),
                          // ),
                          if (widget.gramData.tradeStatus == "Opened" ||
                              isTakeProfitTrade) ...[
                            SizedBox(width: sizes!.widthRatio * 8),
                            // Flexible(
                            //   child: FittedGetGenericText(
                            //     text:
                            //         "${AppLocalizations.of(context)!.idq_currency}  ${CommonService.formatIqdCurrency(pnl)}", //"IQD ${pnl.toStringAsFixed(2)}",
                            //     fontSize: sizes!.responsiveFont(
                            //       phoneVal: 16,
                            //       tabletVal: 18,
                            //     ),
                            //     fontWeight: FontWeight.w400,
                            //     color: pnl > 0
                            //         ? AppColors.greenColor
                            //         : AppColors.red900Color,
                            //   ),
                            // ),
                            Flexible(
                              child: FittedGetGenericText(
                                text: (() {
                                  final isRtl =
                                      Localizations.localeOf(
                                        context,
                                      ).languageCode ==
                                      'ar';
                                  final formattedPnl =
                                      CommonService.formatIqdCurrency(
                                        pnl.abs(),
                                      );
                                  final sign = pnl >= 0 ? '+' : '-';

                                  return isRtl
                                      ? "$formattedPnl$sign ${AppLocalizations.of(context)!.idq_currency}"
                                      : " ${AppLocalizations.of(context)!.idq_currency} $sign $formattedPnl";
                                })(),
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 14,
                                  tabletVal: 16,
                                ),
                                fontWeight: FontWeight.w400,
                                color: pnl >= 0
                                    ? AppColors.greenColor
                                    : AppColors.red900Color,
                              ),
                            ),
                            //                          Flexible(
                            //   child: FittedGetGenericText(
                            //     text: Directionality.of(context) == TextDirection.RTL
                            //         ? "${pnl >= 0 ? '+' : '-'} ${AppLocalizations.of(context)!.idq_currency}  ${CommonService.formatIqdCurrency(pnl.abs())}"
                            //         : " ${AppLocalizations.of(context)!.idq_currency} ${CommonService.formatIqdCurrency(pnl.abs())}${pnl >= 0 ? '+' : '-'}",
                            //     fontSize: sizes!.responsiveFont(
                            //       phoneVal: 16,
                            //       tabletVal: 18,
                            //     ),
                            //     fontWeight: FontWeight.w400,
                            //     color: pnl >= 0 ? AppColors.greenColor : AppColors.red900Color,
                            //   ),
                            // ),
                          ],
                        ],
                      ),
                      ConstPadding.sizeBoxWithHeight(height: 12),
                      widget.gramData.tradeType == "Sell"
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: GetGenericText(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.deal_bought_at_price, //"Bought at Price",
                                    fontSize: sizes!.responsiveFont(
                                      phoneVal: 16,
                                      tabletVal: 18,
                                    ), //16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.grey3Color,
                                    lines: 3,
                                  ),
                                ),
                                SizedBox(width: sizes!.widthRatio * 8),
                                Flexible(
                                  child: FittedGetGenericText(
                                    text:
                                        "${AppLocalizations.of(context)!.idq_currency} ${CommonService.formatIqdCurrency(widget.gramData.buyingPrice)}",
                                    // "IQD ${widget.gramData.buyingPrice?.toStringAsFixed(2)}",
                                    fontSize: sizes!.responsiveFont(
                                      phoneVal: 16,
                                      tabletVal: 18,
                                    ), //16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.grey5Color,
                                  ),
                                ),
                              ],
                            )
                          : SizedBox.shrink(),
                      widget.gramData.tradeType == "Sell"
                          ? ConstPadding.sizeBoxWithHeight(height: 12)
                          : Container(),
                      widget.gramData.tradeType == "Sell"
                          ? Divider(
                              color: AppColors.greyScale900,
                              thickness: 1,
                            )
                          : SizedBox.shrink(),
                      ConstPadding.sizeBoxWithHeight(height: 12),

                      /// Sell/Buy at Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GetGenericText(
                              text:
                                  "${widget.gramData.tradeType == "Sell" ? AppLocalizations.of(context)!.trade_sell : AppLocalizations.of(context)!.gram_buy_word} ${AppLocalizations.of(context)!.deal_at_price}",
                              // "${widget.gramData.tradeType == "Sell" ? "Sell" : "Buy"} at Price",
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 16,
                                tabletVal: 18,
                              ), //16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.grey3Color,
                              lines: 3,
                            ),
                          ),
                          SizedBox(width: sizes!.widthRatio * 8),
                          Flexible(
                            child: FittedGetGenericText(
                              text:
                                  "${AppLocalizations.of(context)!.idq} ${widget.gramData.tradeType == "Sell"
                                      ? (widget.gramData.tradeStatus == "Pending" ? CommonService.formatIqdCurrency(widget.gramData.sellAtProfit) : CommonService.formatIqdCurrency(widget.gramData.sellingPrice))
                                      : widget.gramData.tradeType == "Buy"
                                      ? (widget.gramData.tradeStatus == "Pending" ? CommonService.formatIqdCurrency(widget.gramData.buyAtPrice) : CommonService.formatIqdCurrency(widget.gramData.buyingPrice))
                                      : '0.000'}", // Fallback for unknown trade types
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 16,
                                tabletVal: 18,
                              ), //16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey5Color,
                            ),
                          ),
                        ],
                      ),
                      ConstPadding.sizeBoxWithHeight(height: 12),
                      Divider(
                        color: AppColors.greyScale900,
                        thickness: 1,
                      ),
                      ConstPadding.sizeBoxWithHeight(height: 12),

                      /// Current Price
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     GetGenericText(
                      //       text: widget.gramData.tradeStatus == "Opened"
                      //           //widget.gramData.tradeType == "Sell"
                      //           ? "Current Sell Price"
                      //           : "Current Buy Price",
                      //       fontSize: sizes!.responsiveFont(
                      //         phoneVal: 16,
                      //         tabletVal: 18,
                      //       ), //16,
                      //       fontWeight: FontWeight.w400,
                      //       color: AppColors.grey3Color,
                      //     ),
                      //     GetGenericText(
                      //       text: //widget.gramData.tradeType == "Sell"
                      //       widget.gramData.tradeStatus == "Opened"
                      //           ? "IQD ${goldPriceStateWatchProvider.value?.oneGramSellingPriceInIQD.toStringAsFixed(2)}"
                      //           : "IQD ${goldPriceStateWatchProvider.value?.oneGramBuyingPriceInIQD.toStringAsFixed(2)}",
                      //       fontSize: sizes!.responsiveFont(
                      //         phoneVal: 16,
                      //         tabletVal: 18,
                      //       ), //16,
                      //       fontWeight: FontWeight.w600,
                      //       color: AppColors.grey5Color,
                      //     ),
                      //   ],
                      // ),
                      /// Current Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GetGenericText(
                              text:
                                  (widget.gramData.tradeStatus == "Opened" ||
                                      (widget.gramData.tradeStatus ==
                                              "Pending" &&
                                          widget.gramData.tradeType == "Sell"))
                                  ? AppLocalizations.of(context)!
                                        .deal_current_sell_price //"Current Sell Price"
                                  : AppLocalizations.of(
                                      context,
                                    )!.deal_current_buy_price, //"Current Buy Price",
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 16,
                                tabletVal: 18,
                              ),
                              fontWeight: FontWeight.w400,
                              color: AppColors.grey3Color,
                              lines: 3,
                            ),
                          ),
                          SizedBox(width: sizes!.widthRatio * 8),
                          Flexible(
                            child: FittedGetGenericText(
                              text:
                                  (widget.gramData.tradeStatus == "Opened" ||
                                      (widget.gramData.tradeStatus ==
                                              "Pending" &&
                                          widget.gramData.tradeType == "Sell"))
                                  ? "${AppLocalizations.of(context)!.idq} ${CommonService.formatIqdCurrency(goldPriceStateWatchProvider.value?.oneGramSellingPriceInIQD)}"
                                  : "${AppLocalizations.of(context)!.idq} ${CommonService.formatIqdCurrency(goldPriceStateWatchProvider.value?.oneGramBuyingPriceInIQD)}",
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 16,
                                tabletVal: 18,
                              ),
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey5Color,
                            ),
                          ),
                        ],
                      ),

                      ConstPadding.sizeBoxWithHeight(height: 12),
                      Divider(
                        color: AppColors.greyScale900,
                        thickness: 1,
                      ),
                      ConstPadding.sizeBoxWithHeight(height: 12),

                      /// Trade Money
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GetGenericText(
                              text: AppLocalizations.of(
                                context,
                              )!.grams_card_invest_money, //"Invest Money",
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 16,
                                tabletVal: 18,
                              ), //16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.grey3Color,
                              lines: 3,
                            ),
                          ),
                          SizedBox(width: sizes!.widthRatio * 8),
                          Flexible(
                            child: FittedGetGenericText(
                              text:
                                  "${AppLocalizations.of(context)!.idq_currency} ${CommonService.formatIqdCurrency(widget.gramData.tradeMoney)}",
                              // "IQD ${widget.gramData.tradeMoney?.toStringAsFixed(2) ?? '0.00'}",
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 16,
                                tabletVal: 18,
                              ), //16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey5Color,
                            ),
                          ),
                        ],
                      ),
                      ConstPadding.sizeBoxWithHeight(height: 12),
                      Divider(
                        color: AppColors.greyScale900,
                        thickness: 1,
                      ),
                      ConstPadding.sizeBoxWithHeight(height: 12),
                      // Row(

                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Expanded(
                      //      // flex: 2,
                      //       child: GetGenericText(
                      //         text: AppLocalizations.of(
                      //           context,
                      //         )!.dateTime, //"Date & Time",
                      //         fontSize: sizes!.responsiveFont(
                      //           phoneVal: 16,
                      //           tabletVal: 18,
                      //         ),
                      //         fontWeight: FontWeight.w400,
                      //         color: AppColors.grey3Color,
                      //         lines: 2,
                      //       ),
                      //     ),
                      //     SizedBox(width: sizes!.widthRatio * 8),
                      //     Expanded(
                      //       //flex: 2,
                      //       child: GetGenericText(
                      //         text:
                      //             // _formatIraqGregorianDateTime(
                      //             //   widget.gramData.createdAt?.toString(),
                      //             //   context,
                      //             // ),
                      //             DateTimeHelper.formatLocalDateTime(
                      //               widget.gramData.createdAt?.toString(),
                      //               context,
                      //             ),
                      //         // DateFormat('EEE, dd MMM yyyy HH:mm').format(
                      //         //   DateTime.parse(
                      //         //     widget.gramData.createdAt!.toString(),
                      //         //   ).toLocal(),
                      //         // ),
                      //         fontSize: sizes!.responsiveFont(
                      //           phoneVal: 14,
                      //           tabletVal: 16,
                      //         ),
                      //         fontWeight: FontWeight.w600,
                      //         color: AppColors.grey5Color,
                      //         lines: 3,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // Date & Time Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GetGenericText(
                              text: AppLocalizations.of(context)!.dateTime,
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 16,
                                tabletVal: 18,
                              ),
                              fontWeight: FontWeight.w400,
                              color: AppColors.grey3Color,
                              lines: 2,
                            ),
                          ),
                          SizedBox(width: sizes!.widthRatio * 8),
                          Flexible(
                            // Changed from Expanded to Flexible
                            child: GetGenericText(
                              text: DateTimeHelper.formatLocalDateTime(
                                widget.gramData.createdAt?.toString(),
                                context,
                              ),
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 14,
                                tabletVal: 16,
                              ),
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey5Color,
                              lines: 3,
                              textAlign: TextAlign
                                  .end, // Add this to align text to the right
                            ),
                          ),
                        ],
                      ),
                      ConstPadding.sizeBoxWithHeight(height: 12),
                      Divider(
                        color: AppColors.greyScale900,
                        thickness: 1,
                      ),
                      ConstPadding.sizeBoxWithHeight(height: 12),

                      if (widget.gramData.tradeStatus == "Pending") ...[
                        /// tradeStatus Pending
                        /// Manage options
                        GetGenericText(
                          text: AppLocalizations.of(
                            context,
                          )!.deal_manage_section, //"Manage Deal",
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 16,
                            tabletVal: 18,
                          ),
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey5Color,
                        ).getAlign(),

                        ConstPadding.sizeBoxWithHeight(height: 12),

                        /// Edit Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: GetGenericText(
                                text: AppLocalizations.of(
                                  context,
                                )!.deal_edit_price, //"Edit Price",
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 16,
                                  tabletVal: 18,
                                ), //16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                lines: 3,
                              ),
                            ),
                            Switch.adaptive(
                              activeColor: AppColors.primaryGold500,
                              thumbColor:
                                  WidgetStateProperty.resolveWith<Color>((
                                    Set<WidgetState> states,
                                  ) {
                                    if (states.contains(WidgetState.disabled)) {
                                      return Colors.orange.withValues(
                                        alpha: .48,
                                      );
                                    }
                                    return Colors.white;
                                  }),
                              value: isEditPrice,
                              onChanged: (value) {
                                setState(() {
                                  isEditPrice = value;
                                });
                                if (isEditPrice) {
                                  //SoundPlayer().playSound(AppSounds.successSound);
                                }
                              },
                            ),
                          ],
                        ),

                        /// Is Edit Price
                        if (isEditPrice) ...[
                          Form(
                            key: _formEditPriceKey,
                            child: Column(
                              children: [
                                ConstPadding.sizeBoxWithHeight(height: 10),
                                CommonTextFormField(
                                  focusNode: _focusSellAtPriceNode,
                                  title: "",
                                  hintText: AppLocalizations.of(
                                    context,
                                  )!.deal_price_per_gram, //"Price per gram (IQD)",
                                  labelText: AppLocalizations.of(
                                    context,
                                  )!.deal_gram_price, //"Gram Price",
                                  controller: sellAtPriceController,
                                  // inputFormatters: [
                                  //   DecimalTextInputFormatter(decimalRange: 3),
                                  //   //LengthLimitingTextInputFormatter(15),
                                  // ],
                                  inputFormatters: [
                                    AmountInputFormatter(
                                      maxDigits: 6,
                                    ),
                                  ],
                                  textInputType:
                                      TextInputType.numberWithOptions(
                                        signed: true,
                                        decimal: true,
                                      ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(
                                        context,
                                      )!.deal_enter_amount_IQD; //'Please enter an amount in IQD';
                                    }
                                    final amount = num.tryParse(value);
                                    if (amount == null) {
                                      return AppLocalizations.of(
                                        context,
                                      )!.deal_valid_number; //'Please enter a valid number';
                                    }
                                    if (amount <= 0) {
                                      return AppLocalizations.of(
                                        context,
                                      )!.deal_zero_value_validation; //'Please enter an amount greater than zero';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          ConstPadding.sizeBoxWithHeight(height: 12),

                          ConstPadding.sizeBoxWithHeight(height: 12),
                        ],

                        /// Edit Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: GetGenericText(
                                text: AppLocalizations.of(
                                  context,
                                )!.deal_edit_gram, //"Edit Gram Amount",
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 16,
                                  tabletVal: 18,
                                ), //16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                lines: 3,
                              ),
                            ),
                            Switch.adaptive(
                              activeColor: AppColors.primaryGold500,
                              thumbColor:
                                  WidgetStateProperty.resolveWith<Color>((
                                    Set<WidgetState> states,
                                  ) {
                                    if (states.contains(WidgetState.disabled)) {
                                      return Colors.orange.withValues(
                                        alpha: .48,
                                      );
                                    }
                                    return Colors.white;
                                  }),
                              value: isGramAmountPrice,
                              onChanged: (value) {
                                setState(() {
                                  isGramAmountPrice = value;
                                });
                                if (isGramAmountPrice) {
                                  //SoundPlayer().playSound(AppSounds.successSound);
                                }
                              },
                            ),
                          ],
                        ),

                        /// Is Amount Price
                        if (isGramAmountPrice) ...[
                          Form(
                            key: _formEditAmountKey,
                            child: Column(
                              children: [
                                ConstPadding.sizeBoxWithHeight(height: 10),
                                CommonTextFormField(
                                  focusNode: _focusAmountGramNode,
                                  title: "",
                                  hintText: AppLocalizations.of(
                                    context,
                                  )!.deal_gram_amount, //"Gram Amount",
                                  labelText: AppLocalizations.of(
                                    context,
                                  )!.deal_gram_amount, //"Gram Amount",
                                  controller: gramAmountController,
                                  inputFormatters: [
                                    DecimalAmountInputFormatter(
                                      maxDigits: 4,
                                      decimalRange: 3

                                    ),
                                  ],
                                  textInputType:
                                      TextInputType.numberWithOptions(
                                        signed: true,
                                        decimal: true,
                                      ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(
                                        context,
                                      )!.deal_gram_amount; //'Please enter gram amount';
                                    }
                                    final amount = num.tryParse(value);
                                    if (amount == null) {
                                      return AppLocalizations.of(
                                        context,
                                      )!.deal_valid_number; //'Please enter a valid number';
                                    }
                                    if (amount <= 0) {
                                      return AppLocalizations.of(
                                        context,
                                      )!.deal_zero_value_validation; //'Please enter an amount greater than zero';
                                    }
                                    // Take profit deal: grams must be <= total
                                    if (isTakeProfitTrade &&
                                        widget.gramData.tradeMetal != null &&
                                        amount > widget.gramData.tradeMetal!) {
                                      return '${AppLocalizations.of(context)!.deal_amount_must_less} ${widget.gramData.tradeMetal}';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          ConstPadding.sizeBoxWithHeight(height: 12),
                          ConstPadding.sizeBoxWithHeight(height: 12),
                        ],
                        ConstPadding.sizeBoxWithHeight(height: 12),
                      ],

                      ///Confirmation the cancellation
                      if (widget.gramData.tradeStatus == "Pending") ...[
                        isGramAmountPrice || isEditPrice
                            ? AbsorbPointer(
                                absorbing: !canPendingOrderUseLivePrice,
                                child: Opacity(
                                  opacity: canPendingOrderUseLivePrice
                                      ? 1.0
                                      : 0.5,
                                  child: LoaderButton(
                                    title: AppLocalizations.of(
                                      context,
                                    )!.deal_update_order, //"Update Order",
                                    onTap: () async {
                                      final liveBuyCheck =
                                          ref
                                              .read(goldPriceProvider)
                                              .value
                                              ?.oneGramBuyingPriceInIQD ??
                                          0.0;
                                      final liveSellCheck =
                                          ref
                                              .read(goldPriceProvider)
                                              .value
                                              ?.oneGramSellingPriceInIQD ??
                                          0.0;
                                      if (widget.gramData.tradeType == "Sell" &&
                                          liveSellCheck <= 0) {
                                        Toasts.getErrorToast(
                                          text: AppLocalizations.of(
                                            context,
                                          )!.error_loading_price,
                                          gravity: ToastGravity.TOP,
                                        );
                                        return;
                                      }
                                      if (widget.gramData.tradeType == "Buy" &&
                                          liveBuyCheck <= 0) {
                                        Toasts.getErrorToast(
                                          text: AppLocalizations.of(
                                            context,
                                          )!.error_loading_price,
                                          gravity: ToastGravity.TOP,
                                        );
                                        return;
                                      }

                                      final tradeType =
                                          widget.gramData.tradeType;
                                      final tradeStatus =
                                          widget.gramData.tradeStatus;

                                      if (isEditPrice &&
                                          (sellAtPriceController.text.isEmpty ||
                                              sellAtPriceController.text
                                                      .trim() ==
                                                  "0")) {
                                        Toasts.getErrorToast(
                                          text: AppLocalizations.of(
                                            context,
                                          )!.please_enter_valid_price, //"Please enter a valid price",
                                          gravity: ToastGravity.TOP,
                                        );
                                        return;
                                      }

                                      if (isGramAmountPrice &&
                                          (gramAmountController.text.isEmpty ||
                                              gramAmountController.text
                                                      .trim() ==
                                                  "0")) {
                                        Toasts.getErrorToast(
                                          text: AppLocalizations.of(
                                            context,
                                          )!.deal_enter_valid_gram, //"Please enter a valid gram amount",
                                          gravity: ToastGravity.TOP,
                                        );
                                        return;
                                      }

                                      // Take profit deal: grams must be <= total
                                      if (isGramAmountPrice &&
                                          isTakeProfitTrade &&
                                          widget.gramData.tradeMetal != null) {
                                        final gramAmount = double.tryParse(
                                          gramAmountController.text.trim(),
                                        );
                                        if (gramAmount != null &&
                                            gramAmount >
                                                widget.gramData.tradeMetal!) {
                                          Toasts.getErrorToast(
                                            text:
                                                '${AppLocalizations.of(context)!.deal_amount_must_less} ${widget.gramData.tradeMetal}',
                                            gravity: ToastGravity.TOP,
                                          );
                                          return;
                                        }
                                      }

                                      final double? editedPrice =
                                          double.tryParse(
                                            sellAtPriceController.text.trim(),
                                          );
                                      final double? currentSellPrice =
                                          goldPriceStateWatchProvider
                                              .value
                                              ?.oneGramSellingPriceInIQD;
                                      final double? currentBuyPrice =
                                          goldPriceStateWatchProvider
                                              .value
                                              ?.oneGramBuyingPriceInIQD;

                                      // Pending Sell - edited price must be greater than current sell price
                                      // if (isEditPrice &&
                                      //     tradeStatus == "Pending" &&
                                      //     tradeType == "Sell") {
                                      //   if (editedPrice == null ||
                                      //       currentSellPrice == null ||
                                      //       editedPrice < currentSellPrice) {
                                      //     Toasts.getErrorToast(
                                      //       text:
                                      //           "Please enter a sell price greater than the current sell price (AED ${currentSellPrice?.toStringAsFixed(2) ?? "-"})",
                                      //       gravity: ToastGravity.TOP,
                                      //     );
                                      //     return;
                                      //   }
                                      // }

                                      final bool canSellAtLoss =
                                          ref
                                              .read(homeProvider)
                                              .getHomeFeedResponse
                                              .payload!
                                              .sellAtLoss ??
                                          false;
                                      if (isEditPrice &&
                                          tradeStatus == "Pending" &&
                                          tradeType == "Sell") {
                                        final buyingPrice =
                                            widget.gramData.buyingPrice;

                                        //  CASE 1: Sell at loss (pnl < 0 and sellAtLoss active)
                                        if (pnl < 0 && canSellAtLoss == true) {
                                          if (editedPrice == null ||
                                              currentSellPrice == null ||
                                              editedPrice < currentSellPrice) {
                                            Toasts.getErrorToast(
                                              text:
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.deal_sell_greater_than_current_sell_price(
                                                    currentSellPrice
                                                            ?.toStringAsFixed(
                                                              3,
                                                            ) ??
                                                        "-",
                                                  ),
                                              gravity: ToastGravity.TOP,
                                            );
                                            return;
                                          }
                                        }
                                        //  CASE 2: Normal validation (must be greater than bought price)
                                        else if (editedPrice == null ||
                                            (buyingPrice != 0 &&
                                                editedPrice <= buyingPrice!)) {
                                          Toasts.getErrorToast(
                                            text:
                                                "${AppLocalizations.of(context)!.deal_sell_greater_than_bought} ${buyingPrice?.toStringAsFixed(3) ?? "-"})",
                                            gravity: ToastGravity.TOP,
                                          );
                                          return;
                                        }
                                      }

                                      ////Newly code added for Gift opened order
                                      // NEW VALIDATION: Pending Sell with null buyingPrice - edited price should be >= current sell price
                                      if (isEditPrice &&
                                          tradeStatus == "Pending" &&
                                          widget.gramData.buyingPrice == 0) {
                                        if (editedPrice == null ||
                                            currentSellPrice == null ||
                                            editedPrice < currentSellPrice) {
                                          Toasts.getErrorToast(
                                            text:
                                                "${AppLocalizations.of(context)!.deal_pending_sell_greater_with_zero_buying_than_current_sell} ${currentSellPrice?.toStringAsFixed(3) ?? "-"})",

                                            // "Please enter a sell price greater than or equal to the current sell price (IQD ${currentSellPrice?.toStringAsFixed(2) ?? "-"})",
                                            gravity: ToastGravity.TOP,
                                          );
                                          return;
                                        }
                                      }

                                      // Pending Buy - edited price must be less than or equal to current buy price
                                      if (isEditPrice &&
                                          tradeStatus == "Pending" &&
                                          tradeType == "Buy") {
                                        if (editedPrice == null ||
                                            currentBuyPrice == null ||
                                            editedPrice > currentBuyPrice) {
                                          Toasts.getErrorToast(
                                            text:
                                                "${AppLocalizations.of(context)!.deal_buy_price_less} ${currentBuyPrice?.toStringAsFixed(3) ?? "-"})",

                                            // "Please enter a buy price less than the current buy price (IQD ${currentBuyPrice?.toStringAsFixed(2) ?? "-"})",
                                            gravity: ToastGravity.TOP,
                                          );
                                          return;
                                        }
                                      }

                                      // Show confirmation dialog only after validation passes
                                      await genericPopUpWidget(
                                        context: context,
                                        heading: AppLocalizations.of(
                                          context,
                                        )!.deal_update_confirm_title, //"Confirmation",
                                        subtitle: AppLocalizations.of(
                                          context,
                                        )!.deal_sure_confirm,
                                        //"Are you sure you want to Update this order?",
                                        noButtonTitle: AppLocalizations.of(
                                          context,
                                        )!.no, //"No",
                                        yesButtonTitle: AppLocalizations.of(
                                          context,
                                        )!.yes,
                                        isLoadingState: false,
                                        onNoPress: () {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        onYesPress: () async {
                                          final existingBuyAtPrice =
                                              double.tryParse(
                                                widget.gramData.buyAtPrice
                                                        ?.toString() ??
                                                    "0",
                                              ) ??
                                              0;
                                          final existingSellAtProfit =
                                              double.tryParse(
                                                widget.gramData.sellAtProfit
                                                        ?.toString() ??
                                                    "0",
                                              ) ??
                                              0;
                                          final existingGram =
                                              double.tryParse(
                                                widget.gramData.tradeMetal
                                                        ?.toString() ??
                                                    "0",
                                              ) ??
                                              0;

                                          final updatedGram =
                                              double.tryParse(
                                                gramAmountController.text,
                                              ) ??
                                              existingGram;
                                          final updatedPrice =
                                              double.tryParse(
                                                sellAtPriceController.text,
                                              ) ??
                                              0;

                                          final calculatedTradeMoney = (() {
                                            if (isGramAmountPrice &&
                                                !isEditPrice) {
                                              return tradeType == "Sell"
                                                  ? updatedGram *
                                                        existingSellAtProfit
                                                  : updatedGram *
                                                        existingBuyAtPrice;
                                            } else if (!isGramAmountPrice &&
                                                isEditPrice) {
                                              return existingGram *
                                                  updatedPrice;
                                            } else if (isGramAmountPrice &&
                                                isEditPrice) {
                                              return updatedGram * updatedPrice;
                                            } else {
                                              return widget.gramData.tradeMoney;
                                            }
                                          })();

                                          // Proceed to API call after passing price validation
                                          final updated = tradeType == "Sell"
                                              ? await gramStateReadProvider
                                                    .updateSellOrder(
                                                      context: context,
                                                      tradeId: widget
                                                          .gramData
                                                          .id
                                                          .toString(),
                                                      dealId: widget
                                                          .gramData
                                                          .dealId!,
                                                      tradeMoney:
                                                          calculatedTradeMoney
                                                              .toString(),
                                                      tradeMetal:
                                                          isGramAmountPrice
                                                          ? gramAmountController
                                                                .text
                                                          : widget
                                                                .gramData
                                                                .tradeMetal!
                                                                .toString(),
                                                      sellAtProfit: isEditPrice
                                                          ? sellAtPriceController
                                                                .text
                                                          : widget
                                                                .gramData
                                                                .sellAtProfit
                                                                .toString(),
                                                      sellingPrice: isEditPrice
                                                          ? sellAtPriceController
                                                                .text
                                                          : widget
                                                                .gramData
                                                                .sellAtProfit
                                                                .toString(),
                                                    )
                                              : await gramStateReadProvider
                                                    .updateBuyOrder(
                                                      context: context,
                                                      dealId: widget
                                                          .gramData
                                                          .dealId!,
                                                      tradeMoney:
                                                          calculatedTradeMoney
                                                              .toString(),
                                                      tradeMetal:
                                                          isGramAmountPrice
                                                          ? gramAmountController
                                                                .text
                                                          : widget
                                                                .gramData
                                                                .tradeMetal!
                                                                .toString(),
                                                      buyAtPrice: isEditPrice
                                                          ? sellAtPriceController
                                                                .text
                                                          : widget
                                                                .gramData
                                                                .buyAtPrice
                                                                .toString(),
                                                      buyingPrice: isEditPrice
                                                          ? sellAtPriceController
                                                                .text
                                                          : widget
                                                                .gramData
                                                                .buyAtPrice
                                                                .toString(),
                                                    );

                                          if (!context.mounted) return;
                                          if (!updated) return;

                                          await ref
                                              .read(gramProvider.notifier)
                                              .getUserGramBalance();

                                          if (!context.mounted) return;

                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              )
                            : LoaderButton(
                                title: AppLocalizations.of(
                                  context,
                                )!.deal_cance_title, //"Cancel Order",
                                onTap: () async {
                                  await genericPopUpWidget(
                                    context: context,
                                    heading: AppLocalizations.of(
                                      context,
                                    )!.invest_confirmation_title, //"Confirmation",
                                    subtitle: AppLocalizations.of(
                                      context,
                                    )!.deal_cancel_order, //"Are you sure you want to cancel this order?",
                                    noButtonTitle: AppLocalizations.of(
                                      context,
                                    )!.no, //"No",
                                    yesButtonTitle: AppLocalizations.of(
                                      context,
                                    )!.yes, //"Yes",
                                    isLoadingState: false,
                                    onNoPress: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    onYesPress: () async {
                                      final cancelled =
                                          await gramStateReadProvider
                                              .cancelTradeOrder(
                                                orderId: widget.gramData.id
                                                    .toString(),
                                                context: context,
                                              );
                                      if (!context.mounted) return;
                                      if (!cancelled) return;
                                      await ref
                                          .read(gramProvider.notifier)
                                          .getUserGramBalance();
                                      if (!context.mounted) return;
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                  );
                                  return;
                                },
                              ),
                      ],

                      /// tradeStatus Pending
                      if (widget.gramData.tradeStatus != "Pending") ...[
                        /// Manage options
                        GetGenericText(
                          text: AppLocalizations.of(
                            context,
                          )!.deal_manage_section, //"Manage Deal",
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 16,
                            tabletVal: 18,
                          ),
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey5Color,
                        ).getAlign(),

                        /// Take Profit
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: GetGenericText(
                                text: AppLocalizations.of(
                                  context,
                                )!.deal_take_profit, //"Take Profit",
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 16,
                                  tabletVal: 18,
                                ), //16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                lines: 3,
                              ),
                            ),
                            Switch.adaptive(
                              activeColor: AppColors.primaryGold500,
                              thumbColor:
                                  WidgetStateProperty.resolveWith<Color>((
                                    Set<WidgetState> states,
                                  ) {
                                    if (states.contains(WidgetState.disabled)) {
                                      return Colors.orange.withValues(
                                        alpha: .48,
                                      );
                                    }
                                    return Colors.white;
                                  }),
                              value: isTakeProfit,
                              onChanged: (value) {
                                setState(() {
                                  isTakeProfit = value;
                                });
                                if (isTakeProfit) {
                                  //SoundPlayer().playSound(AppSounds.successSound);
                                }
                              },
                            ),
                          ],
                        ),

                        /// Sell at Profit
                        if (isTakeProfit) ...[
                          Form(
                            key: _formTakeProfitKey,
                            child: Column(
                              children: [
                                ConstPadding.sizeBoxWithHeight(height: 10),
                                CommonTextFormField(
                                  focusNode: _focusSellAtPriceNode,
                                  title: "",
                                  hintText: AppLocalizations.of(
                                    context,
                                  )!.deal_price_per_gram, //"Price per gram (IQD)",
                                  labelText: AppLocalizations.of(
                                    context,
                                  )!.deal_sell_at_price, //"Sell at Price",
                                  controller: sellAtPriceController,

                                  inputFormatters: [
                                    AmountInputFormatter(
                                      maxDigits: 6,
                                    ),
                                  ],
                                  textInputType:
                                      TextInputType.numberWithOptions(
                                        signed: true,
                                        decimal: true,
                                      ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(
                                        context,
                                      )!.deal_enter_amount_IQD; //'Please enter an amount in IQD';
                                    }
                                    final amount = num.tryParse(value);
                                    if (amount == null) {
                                      return AppLocalizations.of(
                                        context,
                                      )!.deal_enter_valid_nmbr; //'Please enter a valid number';
                                    }
                                    if (amount <= 0) {
                                      return AppLocalizations.of(
                                        context,
                                      )!.deal_zero_value_validation; //'Please enter an amount greater than zero';
                                    }
                                    // Price range validation (below field, not popup)
                                    final sellingPrice = ref
                                        .read(goldPriceProvider)
                                        .value
                                        ?.oneGramSellingPriceInIQD;
                                    final buyingPrice =
                                        widget.gramData.buyingPrice;
                                    if (sellingPrice != null &&
                                        buyingPrice != null) {
                                      final roundedInput = double.parse(
                                        (amount.toDouble()).toStringAsFixed(3),
                                      );
                                      final roundedBuying = double.parse(
                                        buyingPrice.toStringAsFixed(3),
                                      );
                                      final roundedSelling = double.parse(
                                        sellingPrice.toStringAsFixed(3),
                                      );
                                      // Must be >= buying price
                                      if (roundedInput < roundedBuying) {
                                        return "${AppLocalizations.of(context)!.greater_or_equal_buy}${roundedBuying.toStringAsFixed(3)}).";
                                      }
                                      // Save profit: buy <= price <= sell (valid)
                                      if (roundedInput >= roundedBuying &&
                                          roundedInput <= roundedSelling) {
                                        return null;
                                      }
                                      // Take profit: price >= sell (valid)
                                      if (roundedInput >= roundedSelling) {
                                        return null;
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          ConstPadding.sizeBoxWithHeight(height: 12),

                          /// Update Deal Position
                          AbsorbPointer(
                            absorbing: !canUseLiveSellForDeal,
                            child: Opacity(
                              opacity: canUseLiveSellForDeal ? 1.0 : 0.5,
                              child: LoaderButton(
                                title: AppLocalizations.of(
                                  context,
                                )!.deal_update_position_btn, //"Update Deal Position",
                                onTap: () async {
                                  // Validate form first (errors show below field)
                                  if (!(_formTakeProfitKey.currentState
                                          ?.validate() ??
                                      false)) {
                                    return;
                                  }
                                  final sellingPrice =
                                      goldPriceStateWatchProvider
                                          .value
                                          ?.oneGramSellingPriceInIQD;
                                  if (sellingPrice == null ||
                                      sellingPrice <= 0) {
                                    Toasts.getErrorToast(
                                      text: AppLocalizations.of(
                                        context,
                                      )!.error_loading_price,
                                      gravity: ToastGravity.TOP,
                                    );
                                    return;
                                  }

                                  final String inputText = sellAtPriceController
                                      .text
                                      .trim();
                                  final double userInput =
                                      double.tryParse(inputText) ?? 0.0;
                                  final buyingPrice =
                                      widget.gramData.buyingPrice;
                                  if (buyingPrice == null) return;

                                  final double roundedInput = double.parse(
                                    userInput.toStringAsFixed(3),
                                  );
                                  final double roundedSelling = double.parse(
                                    sellingPrice.toStringAsFixed(3),
                                  );
                                  final bool saveProfit =
                                      roundedInput < roundedSelling;

                                  // Proceed (validation done in form validator above)
                                  if (_formTakeProfitKey.currentState
                                          ?.validate() ??
                                      false) {
                                    _focusSellAtPriceNode.unfocus();

                                    final kSellingPrice = sellingPrice;
                                    final sellAtProfit = num.parse(inputText);
                                    final newTradeMoney =
                                        sellAtProfit *
                                        widget.gramData.tradeMetal!;

                                    debugPrint(
                                      "newTradeMoney: $newTradeMoney | sellAtProfit: $sellAtProfit | tradeMetal: ${widget.gramData.tradeMetal} | kSellingPrice: $kSellingPrice",
                                    );

                                    // final String confirmationMessage =
                                    //     roundedInput >= roundedSelling
                                    //     ? AppLocalizations.of(context)!.about_take_profit//"You are about to take profit at the selected price."
                                    //     : AppLocalizations.of(context)!.about_take_profit;//"You are about to save your profit at the selected price.";
                                    final num buyAt = num.parse(
                                      (widget.gramData.buyingPrice ?? 0)
                                          .toStringAsFixed(3),
                                    );

                                    final String confirmationMessage =
                                        (roundedInput >= buyAt &&
                                            roundedInput <= roundedSelling)
                                        ? AppLocalizations.of(
                                            context,
                                          )!.about_to_save_profit
                                        : AppLocalizations.of(
                                            context,
                                          )!.about_to_take_profit_message;

                                    //if bool is true than show the user that you want to save profit insteady of you want to update deal

                                    await genericPopUpWidget(
                                      context: context,
                                      heading: AppLocalizations.of(
                                        context,
                                      )!.confirmation, //"Confirmation",
                                      subtitle: confirmationMessage,
                                      // AppLocalizations.of(
                                      //   context,
                                      // )!.deal_update_confirm_message, //"Are you sure you want to update deal position?",
                                      noButtonTitle: AppLocalizations.of(
                                        context,
                                      )!.no, //"No",
                                      yesButtonTitle: AppLocalizations.of(
                                        context,
                                      )!.yes, //"Yes",
                                      isLoadingState: ref
                                          .watch(gramProvider)
                                          .isButtonState,
                                      onNoPress: () {
                                        Navigator.pop(context);
                                      },
                                      onYesPress: () async {
                                        final ok = await tradeStateReadProvider
                                            .updateTradeDealPosition(
                                              dealId: widget.gramData.dealId!,
                                              tradeMoney: newTradeMoney,
                                              tradeMetal:
                                                  widget.gramData.tradeMetal!,
                                              sellAtProfitStatus: isTakeProfit,
                                              sellAtProfit: sellAtProfit,
                                              sellingPrice: double.parse(
                                                sellingPrice.toStringAsFixed(3),
                                              ),
                                              saveProfit: saveProfit,
                                              context: context,
                                            );
                                        if (!context.mounted) return;
                                        if (!ok) return;
                                        await ref
                                            .read(gramProvider.notifier)
                                            .getUserGramBalance();
                                        if (!context.mounted) return;
                                        sellAtPriceController.clear();
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          ConstPadding.sizeBoxWithHeight(height: 12),
                        ],

                        /// Close Deal
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: GetGenericText(
                                text: AppLocalizations.of(
                                  context,
                                )!.deal_close_section, //"Close Deal",
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 16,
                                  tabletVal: 18,
                                ), //16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                lines: 3,
                              ),
                            ),
                            Switch.adaptive(
                              activeColor: AppColors.primaryGold500,
                              thumbColor:
                                  WidgetStateProperty.resolveWith<Color>((
                                    states,
                                  ) {
                                    if (states.contains(WidgetState.disabled)) {
                                      return Colors.orange.withValues(
                                        alpha: .48,
                                      );
                                    }
                                    return Colors.white;
                                  }),
                              value: isCloseEdit,
                              onChanged: (value) async {
                                // Step 1: Optimistic update (UI responds immediately)
                                setState(() {
                                  isCloseEdit = value;
                                });

                                try {
                                  // Step 2: Fire API in background
                                  await ref
                                      .read(homeProvider.notifier)
                                      .getHomeFeed(
                                        context: context,
                                        showLoading:
                                            false, //  disable loading here
                                      );

                                  final payload =
                                      ref
                                          .read(homeProvider)
                                          .getHomeFeedResponse
                                          .payload
                                          ?.sellAtLoss ??
                                      false;

                                  if (!(payload || pnl > 0)) {
                                    // Step 3: If not allowed, revert state + show toast
                                    setState(() {
                                      isCloseEdit = !value;
                                    });

                                    Toasts.getErrorToast(
                                      text: AppLocalizations.of(
                                        context,
                                      )!.deal_cant_close, //"You can't close this deal at loss",
                                      gravity: ToastGravity.TOP,
                                    );
                                  }
                                } catch (e) {
                                  // Step 4: Revert state on error
                                  setState(() {
                                    isCloseEdit = !value;
                                  });

                                  Toasts.getErrorToast(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.something_went_wrong_try_again,
                                    gravity: ToastGravity.TOP,
                                  );
                                }
                              },
                            ),

                            // Switch.adaptive(
                            //   activeColor: AppColors.primaryGold500,
                            //   thumbColor:
                            //       WidgetStateProperty.resolveWith<Color>((
                            //         Set<WidgetState> states,
                            //       ) {
                            //         if (states.contains(WidgetState.disabled)) {
                            //           return Colors.orange.withValues(
                            //             alpha: .48,
                            //           );
                            //         }
                            //         return Colors.white;
                            //       }),
                            //   value: isCloseEdit,
                            //   onChanged: (value) async {
                            //     try {
                            //       await ref
                            //           .read(homeProvider.notifier)
                            //           .getHomeFeed(
                            //             context: context,
                            //             showLoading: true,
                            //           );

                            //       final payload =
                            //           ref
                            //               .read(homeProvider)
                            //               .getHomeFeedResponse
                            //               .payload
                            //               ?.sellAtLoss ??
                            //           false;

                            //       if (payload || pnl > 0) {
                            //         setState(() {
                            //           isCloseEdit = value;
                            //         });
                            //       } else {
                            //         Toasts.getErrorToast(
                            //           text: "You can't close this deal at loss",
                            //           gravity: ToastGravity.TOP,
                            //         );
                            //       }
                            //     } catch (e) {
                            //       Toasts.getErrorToast(
                            //         text:
                            //             "Something went wrong. Please try again.",
                            //         gravity: ToastGravity.TOP,
                            //       );
                            //     }
                            //   },
                            // ),
                          ],
                        ),

                        if (isCloseEdit) ...[
                          Form(
                            key: _formCloseDealKey,
                            child: Column(
                              children: [
                                ConstPadding.sizeBoxWithHeight(height: 10),
                                CommonTextFormField(
                                  focusNode: _focusAmountGramNode,
                                  title: "",
                                  hintText: AppLocalizations.of(
                                    context,
                                  )!.deal_amount_gram, //"Amount Gram",
                                  labelText: AppLocalizations.of(
                                    context,
                                  )!.deal_amount_gram, //"Amount Gram",
                                  controller: closeDealAmountGramController,
                                  inputFormatters: [
                                    AmountInputFormatter(
                                      maxDigits: 4,
                                    ),
                                  ],
                                  textInputType:
                                      TextInputType.numberWithOptions(
                                        signed: true,
                                        decimal: true,
                                      ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(
                                        context,
                                      )!.deal_val_enter_amount; //'Please enter an amount';
                                    }
                                    final amount = num.tryParse(value);
                                    if (amount == null) {
                                      return AppLocalizations.of(
                                        context,
                                      )!.deal_valid_number; //'Please enter a valid number';
                                    }
                                    if (amount <= 0) {
                                      return AppLocalizations.of(
                                        context,
                                      )!.deal_zero_value_validation; //'Please enter an amount greater than zero';
                                    }
                                    if (widget.gramData.tradeMetal != null &&
                                        amount > widget.gramData.tradeMetal!) {
                                      return '${AppLocalizations.of(context)!.deal_amount_must_less} ${widget.gramData.tradeMetal}';
                                      //'Amount must be less than or equal to ${widget.gramData.tradeMetal}';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          ConstPadding.sizeBoxWithHeight(height: 12),

                          /// Close Deal Button
                          AbsorbPointer(
                            absorbing: !canUseLiveSellForDeal,
                            child: Opacity(
                              opacity: canUseLiveSellForDeal ? 1.0 : 0.5,
                              child: LoaderButton(
                                title: AppLocalizations.of(
                                  context,
                                )!.deal_close_section, //"Close Deal",
                                isLoadingState: ref
                                    .watch(gramProvider)
                                    .isButtonState,
                                onTap: () async {
                                  if (_formCloseDealKey.currentState
                                          ?.validate() ??
                                      false) {
                                    // Remove focus to close the keyboard
                                    _focusAmountGramNode.unfocus();

                                    // Get current selling price
                                    final sellingPrice =
                                        goldPriceStateWatchProvider
                                            .value
                                            ?.oneGramSellingPriceInIQD;
                                    if (sellingPrice == null ||
                                        sellingPrice <= 0) {
                                      Toasts.getErrorToast(
                                        text: AppLocalizations.of(
                                          context,
                                        )!.error_loading_price,
                                        gravity: ToastGravity.TOP,
                                      );
                                      return;
                                    }
                                    final kSellingPrice = double.parse(
                                      "$sellingPrice",
                                    );

                                    // Get entered amount
                                    final tradeMetal = num.parse(
                                      closeDealAmountGramController.text
                                          .toString()
                                          .trim(),
                                    );

                                    // Calculate trade money
                                    final newTradeMoney =
                                        tradeMetal * kSellingPrice;

                                    // Get current sellAtLoss setting from home feed
                                    final homeState = ref.read(homeProvider);
                                    final canSellAtLoss =
                                        homeState
                                            .getHomeFeedResponse
                                            .payload
                                            ?.sellAtLoss ??
                                        false;

                                    // Calculate if this would be a loss
                                    final buyingPrice =
                                        widget.gramData.buyingPrice ?? 0;
                                    final wouldBeLoss =
                                        kSellingPrice < buyingPrice;

                                    // If trying to close at a loss and not allowed
                                    if (wouldBeLoss && !canSellAtLoss) {
                                      Toasts.getErrorToast(
                                        text:
                                            "${AppLocalizations.of(context)!.deal_cant_close} ${kSellingPrice.toStringAsFixed(3)}) ${AppLocalizations.of(context)!.is_below_buy} ${buyingPrice.toStringAsFixed(3)}).",

                                        // "You can't close this deal at a loss. Current price ${kSellingPrice.toStringAsFixed(2)}) is below your buying price (AED ${buyingPrice.toStringAsFixed(2)}).",
                                        gravity: ToastGravity.TOP,
                                      );
                                      return;
                                    }

                                    // Show confirmation dialog with appropriate message
                                    await genericPopUpWidget(
                                      context: context,
                                      heading: wouldBeLoss
                                          ? AppLocalizations.of(context)!
                                                .deal_confirm_loss //"Confirm Loss"
                                          : AppLocalizations.of(
                                              context,
                                            )!.deal_confirm_deal_closure, //"Confirm Deal Closure",
                                      subtitle: wouldBeLoss
                                          ? AppLocalizations.of(context)!
                                                .deal_about_to_close //"You're about to close this deal at a loss. Are you sure?"
                                          : "${AppLocalizations.of(context)!.deal_sure_want_to_close} $tradeMetal${AppLocalizations.of(context)!.deal_g_of_deal}", //"Are you sure you want to close ${tradeMetal}g of this deal?",
                                      noButtonTitle: AppLocalizations.of(
                                        context,
                                      )!.cancel, //"Cancel",
                                      yesButtonTitle: wouldBeLoss
                                          ? AppLocalizations.of(context)!
                                                .deal_close_anyway //"Close Anyway"
                                          : AppLocalizations.of(
                                              context,
                                            )!.confirm, //"Confirm",
                                      isLoadingState: ref
                                          .watch(gramProvider)
                                          .isButtonState,
                                      onNoPress: () {
                                        Navigator.pop(context);
                                      },
                                      onYesPress: () async {
                                        final ok = await tradeStateReadProvider
                                            .closeTradeDeal(
                                              dealId: widget.gramData.dealId!,
                                              tradeMoney: newTradeMoney,
                                              tradeMetal: tradeMetal,
                                              sellingPrice: double.parse(
                                                sellingPrice.toStringAsFixed(3),
                                              ),
                                              context: context,
                                            );
                                        if (!context.mounted) return;
                                        if (!ok) return;
                                        closeDealAmountGramController.clear();
                                        setState(() => isCloseEdit = false);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ],

                      ConstPadding.sizeBoxWithHeight(height: 20),
                    ],
                  ).get16HorizontalPadding(),
                ),
        ),
      ),
    );
  }
}
