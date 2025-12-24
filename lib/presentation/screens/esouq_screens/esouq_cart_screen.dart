import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/data_sources/local_database/local_database.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/feature_injection.dart';
import 'package:saveingold_fzco/presentation/screens/fund_screens/add_fund_screen.dart';
import 'package:saveingold_fzco/presentation/screens/setting_screens/setting_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/gram_provider/gram_provider.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/home_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/loader_button.dart';
import 'package:saveingold_fzco/presentation/widgets/pop_up_widget.dart';
import 'package:saveingold_fzco/presentation/widgets/search_check_dropdown.dart';
import 'package:saveingold_fzco/presentation/widgets/text_form_field.dart';

import '../../../data/models/esouq_model/GetAllProductResponse.dart';
import '../../../data/models/home_models/GetHomeFeedResponse.dart';
import '../../sharedProviders/providers/sseGoldPriceProvider/sse_gold_price_provider.dart';
import '../../widgets/shimmers/shimmer_loader.dart';
import 'order_checkout_screen.dart';

enum PaymentMethod {
  metal,
  money,
}

class EsouqCartScreen extends ConsumerStatefulWidget {
  final AllProducts product;
  final String productPrice;
  final String oneGramPriceInAED;

  const EsouqCartScreen({
    required this.product,
    required this.productPrice,
    required this.oneGramPriceInAED,
    super.key,
  });

  @override
  ConsumerState createState() => _EsouqCartScreenState();
}

class _EsouqCartScreenState extends ConsumerState<EsouqCartScreen> {
  final goldQuantityController = TextEditingController();
  var paymentMethod = PaymentMethod.money;

  double totalGrandGoldPayableCharges = 0.0;
  double goldPremium = 0.0;
  double makingCharges = 0.0;
  double valueAtTax = 0.0;
  double deliveryCharges = 0.0;
  double gramBalanceEqual = 0.0;
  double finalGoldPrice = 0.0;
  double totalChargeBeforeGoldPrice = 0.0;
  WalletExists? walletExists;
  final _formKey = GlobalKey<FormState>();
  String _selectedPaymentMethod = "Money";
  late String? selectedDealId = '';
  List? selectedIds;
  List<Map<String, dynamic>> selectedDealsData = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadData();
      fetchData();
    });
    super.initState();
  }

  Future<void> loadData() async {
    final payload = ref.read(homeProvider).getHomeFeedResponse.payload;
    if (payload == null) {
      await ref
          .read(homeProvider.notifier)
          .getHomeFeed(
            context: context,
            showLoading: true,
          );

      final updatedPayload = ref.read(homeProvider).getHomeFeedResponse.payload;

      if (updatedPayload != null) {
        walletExists = updatedPayload.walletExists;
      }
    } else {
      walletExists = payload.walletExists;
    }
    goldQuantityController.text = '1';
    goldQuantityController.addListener(_calculateTotal);
    _calculateTotal();
  }

  void fetchData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gramProvider.notifier).getUserGramBalance();
    });
  }

  @override
  void dispose() {
    goldQuantityController.dispose();
    goldQuantityController.removeListener(_calculateTotal);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  void _calculateTotal() {
    final goldPriceState = ref.watch(goldPriceProvider);
    final oneGramBuyingPriceInAED =
        goldPriceState.value?.oneGramBuyingPriceInAED ?? 0.0;
    setState(() {
      final quantity =
          double.tryParse(goldQuantityController.text.trim()) ?? 1.0;

      // Unified numeric value parser
      double parseValue(String? value) => double.tryParse(value ?? '') ?? 0.0;

      final premiumDiscount = _extractNumericValue(
        widget.product.premiumDiscount,
      );
      final makingChargesValue = _extractNumericValue(
        widget.product.makingCharges,
      );
      final deliveryChargesValue = _extractNumericValue(
        widget.product.deliveryCharges,
      );
      final weightFactor = parseValue(widget.product.weightFactor);
      final fixPricingT4b = oneGramBuyingPriceInAED;

      finalGoldPrice = weightFactor * fixPricingT4b * quantity;

      final totalMakingCharges = makingChargesValue * quantity;
      final totalVatTax = totalMakingCharges * 0.05;

      totalGrandGoldPayableCharges =
          finalGoldPrice +
          totalMakingCharges +
          totalVatTax +
          (premiumDiscount * quantity) +
          deliveryChargesValue;
      totalChargeBeforeGoldPrice =
          totalMakingCharges +
          totalVatTax +
          (premiumDiscount * quantity) +
          deliveryChargesValue;

      // Update display values
      goldPremium = premiumDiscount * quantity;
      makingCharges = totalMakingCharges;
      deliveryCharges = deliveryChargesValue;
      valueAtTax = totalVatTax;

      gramBalanceEqual = weightFactor * quantity;

      // Debug info
      debugPrint('--- Gold Calculation ---');
      debugPrint('Quantity: $quantity');
      debugPrint('Weight Factor: $weightFactor');
      debugPrint('One Gram Price: $fixPricingT4b');
      debugPrint('Final Gold Price: $finalGoldPrice');
      debugPrint('Making Charges: $totalMakingCharges');
      debugPrint('VAT (5%): $totalVatTax');
      debugPrint('Premium Discount: $premiumDiscount');
      debugPrint('Delivery Charges: $deliveryChargesValue');
      debugPrint('Total Payable: $totalGrandGoldPayableCharges');
      debugPrint('Gram Balance Equal: ${gramBalanceEqual.toStringAsFixed(2)}');
    });
  }

  // Handles values like "AED 15.50" or "15.00"
  double _extractNumericValue(String? value) {
    if (value == null) return 0.0;
    final numeric = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(numeric) ?? 0.0;
  }

  // void _calculateTotal() {
  //   setState(() {
  //     // Parse quantity, default to 1 if invalid
  //     final quantity =
  //         double.tryParse(goldQuantityController.text.trim()) ?? 1.0;
  //
  //     // Extract numeric values from product data
  //     final premiumDiscount = _extractNumericValue(
  //       value: widget.product.premiumDiscount ?? '0',
  //     );
  //     final makingChargesValue = _extractNumericValue(
  //       value: widget.product.makingCharges ?? '0',
  //     );
  //     final deliveryChargesValue = _extractNumericValue(
  //       value: widget.product.deliveryCharges ?? '0',
  //     );
  //     // final weightFactor = _extractNumericValue(
  //     //   value: widget.product.weightFactor ?? '0',
  //     // ); // Assuming this exists
  //     //final fixPricingT4b = _extractNumericValue(widget.product.fixPricingT4b ?? '0'); // Assuming this exists
  //
  //     // Step 1: weightFactor * fix pricing (t4b) * quantity = finalGoldPrice
  //     // final finalGoldPrice = weightFactor * fixPricingT4b * quantity;
  //
  //     final weightFactor =
  //         double.tryParse(widget.product.weightFactor ?? "0.0") ?? 0.0;
  //     final fixPricingT4b = double.tryParse(widget.oneGramPriceInAED) ?? 0.0;
  //     // finalGoldPrice =
  //     //     (double.tryParse(widget.product.weightFactor ?? "0.0") ??
  //     //         0.0 * double.parse(widget.oneGramPriceInAED)) *
  //     //     quantity;
  //
  //     finalGoldPrice = weightFactor * fixPricingT4b * quantity;
  //     debugPrint(
  //       "weightFactor: ${(double.tryParse(widget.product.weightFactor ?? "0.0") ?? 0.0 * double.parse(widget.oneGramPriceInAED)) * quantity}",
  //     );
  //     debugPrint("oneGramPriceInAED: ${widget.oneGramPriceInAED}");
  //     debugPrint("finalGoldPrice: $finalGoldPrice");
  //
  //     // Step 2: makingCharges * quantity = totalMakingCharges
  //     final totalMakingCharges = makingChargesValue * quantity;
  //
  //     // Step 3: totalMakingCharges * 0.05 (5%) = totalVatTax
  //     final totalVatTax = totalMakingCharges * 0.05;
  //
  //     // Step 4: finalGoldPrice + totalMakingCharges + totalVatTax + premiumDiscount + deliveryCharges = totalGoldPayableFee
  //     totalGrandGoldPayableCharges =
  //         finalGoldPrice +
  //         totalMakingCharges +
  //         totalVatTax +
  //         premiumDiscount +
  //         deliveryChargesValue;
  //
  //     totalChargeBeforeGoldPrice =
  //         totalMakingCharges +
  //         totalVatTax +
  //         premiumDiscount +
  //         deliveryChargesValue;
  //
  //     // Assuming these are class variables you're updating for display
  //     goldPremium = premiumDiscount;
  //     makingCharges = totalMakingCharges;
  //     deliveryCharges = deliveryChargesValue;
  //     valueAtTax = totalVatTax;
  //
  //     // Calculate balance (assuming 310 is the gold live pricing divisor)
  //     gramBalanceEqual =
  //         double.parse(widget.product.weightFactor ?? "0.0") * quantity;
  //
  //     // For debugging (optional)
  //     debugPrint('Final Gold Price: $finalGoldPrice');
  //     debugPrint('Total Making Charges: $totalMakingCharges');
  //     debugPrint('VAT: $totalVatTax');
  //     debugPrint('Total Gold Payable: $totalGrandGoldPayableCharges');
  //     debugPrint('gramBalanceEqual: ${gramBalanceEqual.toStringAsFixed(3)}');
  //   });
  // }
  //
  // // Extract numeric values from product data
  // double _extractNumericValue({required String value}) {
  //   return double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
  // }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    final gramState = ref.watch(gramProvider);
    final goldPriceState = ref.watch(goldPriceProvider);

    if (goldPriceState.hasValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateTotal();
      });
    }
    //final gramStateWatchProvider = ref.watch(gramProvider);
    // final goldPriceStateWatchProvider = ref.watch(goldPriceProvider);

    // final oneGramBuyingPriceInAED =
    //     goldPriceStateWatchProvider.value?.oneGramBuyingPriceInAED ?? 0.0;

    /// refresh calculate total
    // _calculateTotal();
    final mainStateWatchProvider = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: AppColors.greyScale1000,
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.esouqCart, //"E-souq Cart",
          fontSize: sizes!.responsiveFont(
            phoneVal: 20,
            tabletVal: 24,
          ), //24,
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: sizes!.height,
          width: sizes!.width,
          decoration: const BoxDecoration(
            color: AppColors.greyScale1000,
          ),
          child: SafeArea(
            child:
                mainStateWatchProvider.loadingState == LoadingState.loading ||
                    gramState.loadingState == LoadingState.loading
                ? Center(
                    child: ShimmerLoader(
                      loop: 5,
                    ),
                  ).get20HorizontalPadding()
                :
                  // mainStateWatchProvider.loadingState == LoadingState.error
                  //     ? Center(
                  //         child: InkWell(
                  //           onTap: () {
                  //             loadData();
                  //           },
                  //           child: GetGenericText(
                  //             text: "Error While Loading data Click to retry",
                  //             fontSize: sizes!.responsiveFont(
                  //               phoneVal: 14,
                  //               tabletVal: 16,
                  //             ), // 14,
                  //             fontWeight: FontWeight.w500,
                  //             color: AppColors.grey2Color,
                  //           ),
                  //         ),
                  //       )
                  //     :
                  SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: sizes!.widthRatio * 80,
                                height: sizes!.heightRatio * 80,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold500,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        widget.product.imageUrl!.isNotEmpty
                                        ? widget
                                              .product
                                              .imageUrl!
                                              .first //.toString()
                                        : "https://saveingoldbucket.s3.me-central-1.amazonaws.com/default/Screenshot+2025-03-15+at+1.31.53%E2%80%AFPM.png",
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => SizedBox(
                                      height: sizes!.heightRatio * 20,
                                      width: sizes!.widthRatio * 20,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              ),
                              ConstPadding.sizeBoxWithWidth(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GetGenericText(
                                    text:
                                        "${widget.product.productName?.toUpperCase()}",
                                    fontSize: sizes!.responsiveFont(
                                      phoneVal: 16,
                                      tabletVal: 18,
                                    ),
                                    //16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  ConstPadding.sizeBoxWithHeight(height: 4),
                                  SizedBox(
                                    width: sizes!.widthRatio * 140,
                                    height: sizes!.heightRatio * 40,
                                    child: CommonTextFormField(
                                      title: "title",
                                      hintText: AppLocalizations.of(
                                        context,
                                      )!.quantity, //"Quantity",
                                      labelText: AppLocalizations.of(
                                        context,
                                      )!.quantity, //"Quantity",
                                      controller: goldQuantityController,
                                      textInputType: TextInputType.number,
                                      // inputFormatters: [
                                      //   FilteringTextInputFormatter.digitsOnly
                                      // ],
                                      onChanged: (value) {
                                        _calculateTotal();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ConstPadding.sizeBoxWithHeight(height: 16),
                          GetGenericText(
                            text: AppLocalizations.of(
                              context,
                            )!.paymentMethod, //"Payment Method",
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF2F2F7),
                          ).getAlign(),
                          ConstPadding.sizeBoxWithHeight(height: 16),
                          Consumer(
                            builder: (context, ref, child) {
                              final gramState = ref.watch(gramProvider);

                              if (gramState.loadingState ==
                                  LoadingState.loading) {
                                return const Center(
                                  child: ShimmerLoader(loop: 1),
                                );
                              }

                              final hasGramDeals =
                                  gramState.gramApiResponseModel.payload?.any(
                                    (deal) =>
                                        deal.tradeType == 'Buy' &&
                                        deal.tradeStatus == 'Opened',
                                  ) ??
                                  false;
                              final dropdownItems = hasGramDeals
                                  ? ['Money', 'Metal']
                                  : ['Money'];

                              // Map English value -> Display text based on locale
                              final isArabic =
                                  Directionality.of(context) ==
                                  TextDirection.rtl;
                              final Map<String, String> displayMap = {
                                'Money': isArabic
                                    ? AppLocalizations.of(context)!.money
                                    : 'Money',
                                'Metal': isArabic
                                    ? AppLocalizations.of(context)!.metal
                                    : 'Metal',
                              };

                              return DropdownButtonFormField<String>(
                                dropdownColor: AppColors.primaryGold500,
                                decoration: InputDecoration(
                                  labelText: isArabic
                                      ? 'اختر خيار'
                                      : 'Select an option',
                                  labelStyle: TextStyle(
                                    color: AppColors.whiteColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: GoogleFonts.roboto().fontFamily,
                                  ),
                                  hintStyle: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.secondaryColor,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.secondaryColor,
                                    ),
                                  ),
                                ),
                                value: _selectedPaymentMethod,
                                items: dropdownItems
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value: item, // Keep English for logic
                                        child: GetGenericText(
                                          text:
                                              displayMap[item] ??
                                              item, // Show Arabic if RTL
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFFD1D1D6),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPaymentMethod = value!;
                                    if (_selectedPaymentMethod == "Money" ||
                                        !hasGramDeals) {
                                      selectedIds = null;
                                      selectedDealsData = [];
                                      selectedDealId = null;
                                    }
                                  });
                                },
                                validator: (value) => value == null
                                    ? (isArabic
                                          ? 'يرجى اختيار خيار'
                                          : 'Please select an option')
                                    : null,
                              );
                            },
                          ),

                          // Consumer(
                          //   builder: (context, ref, child) {
                          //     final gramState = ref.watch(gramProvider);
                          //     // 1. Show loader while data is loading
                          //     if (gramState.loadingState ==
                          //         LoadingState.loading) {
                          //       return const Center(
                          //         child: ShimmerLoader(loop: 1),
                          //       );
                          //     }
                          //     // 3. Check for active "Buy" deals
                          //     final hasGramDeals =
                          //         gramState.gramApiResponseModel.payload?.any(
                          //           (deal) =>
                          //               deal.tradeType == 'Buy' &&
                          //               deal.tradeStatus == 'Opened',
                          //         ) ??
                          //         false;
                          //     final dropdownItems = hasGramDeals
                          //         ? ['Money', 'Metal']
                          //         : ['Money'];

                          //     return DropdownButtonFormField<String>(
                          //       dropdownColor: AppColors.primaryGold500,
                          //       decoration: InputDecoration(
                          //         labelText: AppLocalizations.of(
                          //           context,
                          //         )!.selectOption, //"Select an option",
                          //         labelStyle: TextStyle(
                          //           color: AppColors.whiteColor,
                          //           fontSize: 16,
                          //           fontWeight: FontWeight.w400,
                          //           fontFamily: GoogleFonts.roboto().fontFamily,
                          //         ),
                          //         hintStyle: GoogleFonts.roboto(
                          //           fontSize: 16,
                          //           fontWeight: FontWeight.w400,
                          //           color: AppColors.secondaryColor,
                          //         ),
                          //         border: OutlineInputBorder(
                          //           borderSide: BorderSide(
                          //             color: AppColors.secondaryColor,
                          //           ),
                          //         ),
                          //         enabledBorder: OutlineInputBorder(
                          //           borderSide: BorderSide(
                          //             color: AppColors.secondaryColor,
                          //           ),
                          //         ),
                          //         focusedBorder: OutlineInputBorder(
                          //           borderSide: BorderSide(
                          //             color: AppColors.secondaryColor,
                          //           ),
                          //         ),
                          //         errorBorder: OutlineInputBorder(
                          //           borderSide: BorderSide(
                          //             color: Colors.redAccent,
                          //           ),
                          //         ),
                          //         contentPadding: EdgeInsets.symmetric(
                          //           horizontal: 12,
                          //           vertical: 8,
                          //         ),
                          //       ),
                          //       value: _selectedPaymentMethod,
                          //       items: dropdownItems
                          //           .map(
                          //             (item) => DropdownMenuItem(
                          //               value: item,
                          //               child: GetGenericText(
                          //                 text: item,
                          //                 fontSize: 16,
                          //                 fontWeight: FontWeight.w400,
                          //                 color: Color(0xFFD1D1D6),
                          //               ),
                          //             ),
                          //           )
                          //           .toList(),
                          //       onChanged: (value) {
                          //         setState(() {
                          //           _selectedPaymentMethod = value!;
                          //           // Reset selected deals if switching to Money or no deals available
                          //           if (_selectedPaymentMethod == "Money" ||
                          //               !hasGramDeals) {
                          //             selectedIds = null;
                          //             selectedDealsData = [];
                          //             selectedDealId = null;
                          //           }
                          //         });
                          //       },
                          //       validator: (value) => value == null
                          //           ? AppLocalizations.of(context)!
                          //                 .selectOption //'Please select an option'
                          //           : null,
                          //     );
                          //   },
                          // ),
                          ConstPadding.sizeBoxWithHeight(height: 16),
                          _selectedPaymentMethod == "Metal"
                              ? Consumer(
                                  builder: (context, ref, child) {
                                    final gramState = ref.watch(gramProvider);
                                    final quantityText = goldQuantityController
                                        .text
                                        .trim();
                                    final quantity =
                                        double.tryParse(quantityText) ?? 0;

                                    if (gramState.loadingState ==
                                        LoadingState.loading) {
                                      return const CircularProgressIndicator();
                                    }

                                    if (gramState
                                            .gramApiResponseModel
                                            .payload
                                            ?.isEmpty ??
                                        true) {
                                      return Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.no_gram_deal_available,
                                        //"No gram deals available",
                                        style: TextStyle(color: Colors.white),
                                      );
                                    }

                                    final filteredDeals = gramState
                                        .gramApiResponseModel
                                        .payload!
                                        .where(
                                          (deal) =>
                                              deal.tradeType == 'Buy' &&
                                              deal.tradeStatus == 'Opened',
                                        )
                                        .toList();

                                    return GestureDetector(
                                      onTap: () {
                                        if (quantity <= 0) {
                                          Fluttertoast.showToast(
                                            msg: AppLocalizations.of(
                                              context,
                                            )!.valid_quantitty, //"Please enter a valid quantity.",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.TOP,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                          return;
                                        }
                                      },
                                      child: AbsorbPointer(
                                        absorbing: quantity <= 0,
                                        child: Opacity(
                                          opacity: quantity <= 0 ? 0.5 : 1.0,
                                          child: SearchableWithCheckBox(
                                            iconString:
                                                "assets/svg/arrow_down.svg",
                                            title: AppLocalizations.of(
                                              context,
                                            )!.gift_select_gram,
                                            items: filteredDeals
                                                .map<String>(
                                                  (deal) =>
                                                      "${deal.dealId} - ${deal.tradeType == "Buy" ?
                                                       AppLocalizations.of(context)!.buy 
                                                       : AppLocalizations.of(context)!.sell} ${deal.tradeMetal!.toStringAsFixed(2)}g ${AppLocalizations.of(context)!.g_Gold}",
                                                )
                                                .toList(),
                                            label: AppLocalizations.of(
                                              context,
                                            )!.gramDeal,
                                            hint: quantity <= 0
                                                ? AppLocalizations.of(context)!
                                                      .gift_enter_qu //"Enter valid quantity first"
                                                : AppLocalizations.of(
                                                    context,
                                                  )!.plz_choose_deal, //"Please choose a deal",
                                            gramBalanceEqual: gramBalanceEqual,
                                            selectedItems: selectedIds != null
                                                ? selectedIds!.map((id) {
                                                    final deal = filteredDeals
                                                        .firstWhere(
                                                          (d) =>
                                                              d.dealId
                                                                  .toString() ==
                                                              id,
                                                        );
                                                    return "${deal.dealId} - ${deal.tradeType} ${deal.tradeMetal!.toStringAsFixed(2)}g gold";
                                                  }).toList()
                                                : [],
                                            onChanged:
                                                (List<String> selectedList) {
                                                  if (selectedList.isEmpty) {
                                                    setState(() {
                                                      selectedIds = null;
                                                      selectedDealsData = [];
                                                      selectedDealId = null;
                                                    });
                                                    return;
                                                  }

                                                  List<Map<String, dynamic>>
                                                  newSelectedDeals = [];
                                                  double totalSelectedGrams =
                                                      0.0;

                                                  for (var item
                                                      in selectedList) {
                                                    final dealId = item
                                                        .split(" - ")
                                                        .first
                                                        .trim();
                                                    final deal = filteredDeals
                                                        .firstWhere(
                                                          (d) =>
                                                              d.dealId
                                                                  .toString() ==
                                                              dealId,
                                                        );
                                                    final dealGrams =
                                                        deal.tradeMetal ?? 0;

                                                    if (totalSelectedGrams +
                                                            dealGrams >
                                                        gramBalanceEqual) {
                                                      final remainingGrams =
                                                          gramBalanceEqual -
                                                          totalSelectedGrams;
                                                      if (remainingGrams > 0) {
                                                        newSelectedDeals.add({
                                                          "tradeId": deal.id,
                                                          "dealId": deal.dealId,
                                                          "amount":
                                                              remainingGrams,
                                                        });
                                                        totalSelectedGrams +=
                                                            remainingGrams;
                                                      }
                                                      break;
                                                    } else {
                                                      newSelectedDeals.add({
                                                        "tradeId": deal.id,
                                                        "dealId": deal.dealId,
                                                        "amount": dealGrams,
                                                      });
                                                      totalSelectedGrams +=
                                                          dealGrams;
                                                    }
                                                  }

                                                  setState(() {
                                                    selectedIds =
                                                        newSelectedDeals
                                                            .map(
                                                              (
                                                                deal,
                                                              ) => deal["dealId"]
                                                                  .toString(),
                                                            )
                                                            .toList();
                                                    selectedDealsData =
                                                        newSelectedDeals;
                                                    selectedDealId =
                                                        selectedIds!.isNotEmpty
                                                        ? selectedIds!.first
                                                        : null;
                                                  });
                                                },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : const SizedBox.shrink(),
                          ConstPadding.sizeBoxWithHeight(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GetGenericText(
                                text: AppLocalizations.of(
                                  context,
                                )!.currentBalance, //"Current Balance",
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 14,
                                  tabletVal: 16,
                                ), // 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey2Color,
                              ),
                              _selectedPaymentMethod == "Money"
                                  ? GetGenericText(
                                      text:
                                          "${CommonService.convertToShortNum(
                                            num: double.tryParse(
                                                  "${walletExists?.moneyBalance!.toStringAsFixed(2)}",
                                                ) ?? 0.0,
                                          )} ${AppLocalizations.of(context)!.aed_currency}",
                                      fontSize: sizes!.isPhone ? 16 : 20,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.grey6Color,
                                      textAlign: TextAlign.center,
                                    )
                                  : GetGenericText(
                                      // text: "${walletExists?.metalBalance} Gram",
                                      // ${CommonService.convertWeight(
                                      //   grams: double.parse(
                                      //     "${walletExists?.metalBalance}",
                                      //   ),
                                      // Gram",
                                      text: CommonService.convertToWeight(
                                        num: double.parse(
                                          "${walletExists?.metalBalance}",
                                        ),
                                        context: context,
                                      ),
                                      fontSize: sizes!.isPhone ? 16 : 20,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.grey6Color,
                                      textAlign: TextAlign.center,
                                    ),
                            ],
                          ),
                          ConstPadding.sizeBoxWithHeight(height: 16),
                          GetGenericText(
                            text: AppLocalizations.of(
                              context,
                            )!.charges, //"Charges",
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 16,
                              tabletVal: 18,
                            ),
                            //16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey6Color,
                          ).getAlign(),
                          ConstPadding.sizeBoxWithHeight(height: 16),
                          _selectedPaymentMethod == "Money"
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GetGenericText(
                                      text: AppLocalizations.of(
                                        context,
                                      )!.goldPrice, //"Gold Price",
                                      fontSize: sizes!.responsiveFont(
                                        phoneVal: 14,
                                        tabletVal: 16,
                                      ), //14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.grey2Color,
                                    ),
                                    GetGenericText(
                                      text: //oneGramBuyingPriceInAED
                                          "${finalGoldPrice.toStringAsFixed(2)} ${AppLocalizations.of(context)!.aed_currency}",
                                      fontSize: sizes!.responsiveFont(
                                        phoneVal: 14,
                                        tabletVal: 16,
                                      ), //14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.grey6Color,
                                    ),
                                  ],
                                )
                              : SizedBox.shrink(),
                          _selectedPaymentMethod == "Money"
                              ? ConstPadding.sizeBoxWithHeight(height: 8)
                              : SizedBox.shrink(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GetGenericText(
                                text: AppLocalizations.of(
                                  context,
                                )!.premium, //"Premium",
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 14,
                                  tabletVal: 16,
                                ), //14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey2Color,
                              ),
                              GetGenericText(
                                text:
                                    "${goldPremium.toStringAsFixed(2)} ${AppLocalizations.of(context)!.aed_currency}",
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 14,
                                  tabletVal: 16,
                                ), //14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey6Color,
                              ),
                            ],
                          ),
                          ConstPadding.sizeBoxWithHeight(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GetGenericText(
                                text: AppLocalizations.of(
                                  context,
                                )!.making, //"Making",
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 14,
                                  tabletVal: 16,
                                ), //14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey2Color,
                              ),
                              GetGenericText(
                                text:
                                    "${makingCharges.toStringAsFixed(2)} ${AppLocalizations.of(context)!.aed_currency}",
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 14,
                                  tabletVal: 16,
                                ), //14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey6Color,
                              ),
                            ],
                          ),
                          ConstPadding.sizeBoxWithHeight(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GetGenericText(
                                text: AppLocalizations.of(
                                  context,
                                )!.vat, //"VAT",
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 14,
                                  tabletVal: 16,
                                ), //14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey2Color,
                              ),
                              GetGenericText(
                                text:
                                    "${valueAtTax.toStringAsFixed(2)} ${AppLocalizations.of(context)!.aed_currency}",
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 14,
                                  tabletVal: 16,
                                ), //14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey6Color,
                              ),
                            ],
                          ),
                          ConstPadding.sizeBoxWithHeight(height: 8),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     GetGenericText(
                          //       text: "Delivery Charges",
                          //       fontSize: sizes!.responsiveFont(
                          //         phoneVal: 14,
                          //         tabletVal: 16,
                          //       ), // 14,
                          //       fontWeight: FontWeight.w500,
                          //       color: AppColors.grey2Color,
                          //     ),
                          //     GetGenericText(
                          //       text:
                          //           "${widget.product.deliveryCharges.toString()} AED",
                          //       fontSize: sizes!.responsiveFont(
                          //         phoneVal: 14,
                          //         tabletVal: 16,
                          //       ), //14,
                          //       fontWeight: FontWeight.w500,
                          //       color: AppColors.grey6Color,
                          //     ),
                          //   ],
                          // ),
                          // ConstPadding.sizeBoxWithHeight(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GetGenericText(
                                text: AppLocalizations.of(
                                  context,
                                )!.totalCharges, //"Total Charges",
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 14,
                                  tabletVal: 16,
                                ), // 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey2Color,
                              ),
                              GetGenericText(
                                text:
                                    "${(totalChargeBeforeGoldPrice - deliveryCharges).toStringAsFixed(2)} ${AppLocalizations.of(context)!.aed_currency}",
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 14,
                                  tabletVal: 16,
                                ), //14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey6Color,
                              ),
                            ],
                          ),
                          ConstPadding.sizeBoxWithHeight(height: 24),

                          Visibility(
                            visible: _selectedPaymentMethod == "Metal",
                            child: GetGenericText(
                              text:
                                  "${AppLocalizations.of(context)!.all_additional_charge} ${(totalChargeBeforeGoldPrice - deliveryCharges).toStringAsFixed(2)}${AppLocalizations.of(context)!.will_deducted}",
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 12,
                                tabletVal: 14,
                              ), //12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFD1D1D6),
                            ),
                          ),
                          ConstPadding.sizeBoxWithHeight(height: 16),
                          // const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GetGenericText(
                                text: AppLocalizations.of(
                                  context,
                                )!.grandTotal, //"Grand Total",
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 20,
                                  tabletVal: 22,
                                ), // 20,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey2Color,
                              ),
                              _selectedPaymentMethod == "Money"
                                  ? GetGenericText(
                                      text:
                                          "${(totalGrandGoldPayableCharges - deliveryCharges).toStringAsFixed(2)} ${AppLocalizations.of(context)!.aed_currency}",
                                      fontSize: sizes!.responsiveFont(
                                        phoneVal: 18,
                                        tabletVal: 20,
                                      ), //20,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.grey6Color,
                                    )
                                  : GetGenericText(
                                      text:
                                          "${(gramBalanceEqual).toStringAsFixed(2)} ${AppLocalizations.of(context)!.esouq_gram_balance}",
                                      fontSize: sizes!.responsiveFont(
                                        phoneVal: 16,
                                        tabletVal: 20,
                                      ), //20,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.grey6Color,
                                    ),
                            ],
                          ),
                          ConstPadding.sizeBoxWithHeight(height: 20),

                          LoaderButton(
                            title: AppLocalizations.of(
                              context,
                            )!.buy_now, //"Buy Now",
                            onTap: () async {
                              final quantityText = goldQuantityController.text
                                  .trim();

                              // Validate quantity
                              final quantity = num.tryParse(quantityText);
                              if (quantity == null || quantity <= 0) {
                                if (context.mounted) {
                                  Toasts.getErrorToast(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.valid_quantitty, //'Please enter a valid quantity',
                                    gravity: ToastGravity.TOP,
                                  );
                                }
                                return;
                              }

                              // Parse wallet balances
                              double walletBalance =
                                  double.tryParse(
                                    walletExists?.moneyBalance?.toString() ??
                                        "0",
                                  ) ??
                                  0.0;
                              double walletMetal =
                                  double.tryParse(
                                    walletExists?.metalBalance?.toString() ??
                                        "0",
                                  ) ??
                                  0.0;

                              getLocator<Logger>().d(
                                "Wallet - Balance: ${walletBalance.toStringAsFixed(2)}, Metal: ${walletMetal.toStringAsFixed(2)}",
                              );

                              // Small threshold to avoid floating-point precision issues
                              const double epsilon = 0.0001;

                              // Check if both wallet balances are near zero
                              if ((walletBalance).abs() < epsilon &&
                                  (walletMetal).abs() < epsilon) {
                                await showInsufficientBalancePopup();
                                return;
                              }

                              // Metal payment validations
                              if (_selectedPaymentMethod == "Metal") {
                                // Check if any deals are selected
                                if (selectedDealsData.isEmpty) {
                                  if (context.mounted) {
                                    Toasts.getErrorToast(
                                      text: AppLocalizations.of(
                                        context,
                                      )!.select_checkout_deal, //'Please select deals for checkout',
                                      gravity: ToastGravity.TOP,
                                    );
                                  }
                                  return;
                                }

                                // Calculate total selected grams
                                final totalSelectedGrams = selectedDealsData
                                    .fold<double>(
                                      0.0,
                                      (sum, deal) =>
                                          sum +
                                          (deal["amount"] as num).toDouble(),
                                    );

                                // Validate against required grams (with 0.001g tolerance)
                                if (totalSelectedGrams <
                                    gramBalanceEqual - 0.001) {
                                  if (context.mounted) {
                                    Toasts.getErrorToast(
                                      text:
                                          '${AppLocalizations.of(context)!.gift_selected} ${totalSelectedGrams.toStringAsFixed(2)}${AppLocalizations.of(context)!.g_less_than_req} ${gramBalanceEqual.toStringAsFixed(2)}${AppLocalizations.of(context)!.g_less_than_req}',
                                      // 'Selected ${totalSelectedGrams.toStringAsFixed(2)}g is less than required ${gramBalanceEqual.toStringAsFixed(2)}g',
                                      gravity: ToastGravity.TOP,
                                    );
                                  }
                                  return;
                                }
                              }
                              // if want to get the correct like for once 31.10347

                              //   if (totalSelectedGrams <
                              //       gramBalanceEqual - 0.001) {
                              //     if (context.mounted) {
                              //       final selected = totalSelectedGrams
                              //           .toStringAsFixed(2);
                              //       final required = gramBalanceEqual
                              //           .toStringAsFixed(5);

                              //       Toasts.getErrorToast(
                              //         text:
                              //             //' selected $selected  req $required',

                              //         '${AppLocalizations.of(context)!.gift_selected} $selected ${AppLocalizations.of(context)!.g_less_than_req} $required ${AppLocalizations.of(context)!.gram}',

                              //         // Example output (in English):
                              //         // "Selected 1.245g is less than required 1.300g"
                              //         gravity: ToastGravity.TOP,
                              //       );
                              //     }
                              //     return;
                              //   }
                              // }

                              // Check balance sufficiency
                              final isMoneyPayment =
                                  _selectedPaymentMethod == "Money";
                              final requiredMoneyAmount =
                                  totalGrandGoldPayableCharges;
                              final requiredGramMetal = gramBalanceEqual;
                              final isDemo =
                                  await LocalDatabase.instance.getIsDemo() ??
                                  false;

                              if (!isDemo &&
                                      (isMoneyPayment &&
                                          walletBalance <
                                              requiredMoneyAmount) ||
                                  !isDemo &&
                                      (!isMoneyPayment &&
                                          walletMetal < requiredGramMetal)) {
                                if (!context.mounted) return;
                                showInsufficientBalancePopup();
                                return;
                              }

                              //check for demo user
                              if (isDemo &&
                                      (isMoneyPayment &&
                                          walletBalance <
                                              requiredMoneyAmount) ||
                                  isDemo &&
                                      (!isMoneyPayment &&
                                          walletMetal < requiredGramMetal)) {
                                if (!context.mounted) return;
                                showInsufficientBalancePopupforDemo();
                                return;
                              }

                              // Proceed to checkout
                              if (!context.mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderCheckoutScreen(
                                    product: widget.product,
                                    paymentMethod: isMoneyPayment
                                        ? "Money"
                                        : "Metal",
                                    productId: widget.product.id.toString(),
                                    goldPrice: double.parse(
                                      widget.productPrice,
                                    ),
                                    goldQuantity:
                                        double.tryParse(
                                          goldQuantityController.text,
                                        ) ??
                                        0.0,
                                    deliveryCharges: deliveryCharges,
                                    makingCharges: makingCharges,
                                    valueAtTax: valueAtTax,
                                    premiumDiscount: goldPremium,
                                    totalCharges: totalChargeBeforeGoldPrice,
                                    grandPayableTotalGramOrMoney: isMoneyPayment
                                        ? requiredMoneyAmount
                                        : requiredGramMetal,
                                    selectedPaymentMethod:
                                        _selectedPaymentMethod,
                                    selectedDealsData: selectedDealsData,
                                    currentGoldPrice: goldPriceState.value?.oneGramBuyingPriceInAED ?? 00,
                                  ),
                                ),
                              );
                            },
                          ),
                          // LoaderButton(
                          //   title: "Buy Now",
                          //   onTap: () async {
                          //     // Parse wallet balances with proper precision
                          //     double walletBalance = double.tryParse(
                          //             walletExists?.moneyBalance?.toString() ?? "0") ??
                          //         0.0;
                          //     double walletMetal = double.tryParse(
                          //             walletExists?.metalBalance?.toString() ?? "0") ??
                          //         0.0;
                          //
                          //     getLocator<Logger>().d(
                          //       "Wallet - Balance: ${walletBalance.toStringAsFixed(3)}, Metal: ${walletMetal.toStringAsFixed(3)}",
                          //     );
                          //
                          //     // Small threshold to avoid floating-point precision issues
                          //     const double epsilon = 0.0001;
                          //
                          //     // Check if both walletBalance and walletMetal are near zero
                          //     if ((walletBalance).abs() < epsilon &&
                          //         (walletMetal).abs() < epsilon) {
                          //       await showInsufficientBalancePopup();
                          //       return;
                          //     }
                          //
                          //     bool isMoneyPayment =
                          //         paymentMethod == PaymentMethod.money;
                          //     double requiredAmount = totalGrandGoldPayableCharges;
                          //
                          //     // Ensure selected payment method has sufficient balance
                          //     if ((isMoneyPayment && walletBalance < requiredAmount) ||
                          //         (!isMoneyPayment && walletMetal < requiredAmount)) {
                          //       if (!context.mounted) return;
                          //       await showInsufficientBalancePopup();
                          //       return;
                          //     }
                          //
                          //     // Determine payment method and amount
                          //     String paymentMethodString =
                          //         isMoneyPayment ? "Money" : "Metal";
                          //     double grandTotal =
                          //         isMoneyPayment ? requiredAmount : gramBalanceEqual;
                          //
                          //     debugPrint("GrandTotal: $grandTotal");
                          //
                          //     if (!context.mounted) return;
                          //
                          //     // Navigate to Order Checkout
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => OrderCheckoutScreen(
                          //           product: widget.product,
                          //           paymentMethod: paymentMethodString,
                          //           productId: widget.product.id.toString(),
                          //           goldPrice: double.parse(widget.productPrice),
                          //           goldQuantity:
                          //               double.tryParse(goldQuantityController.text) ??
                          //                   0.0,
                          //           deliveryCharges: deliveryCharges,
                          //           makingCharges: makingCharges,
                          //           valueAtTax: valueAtTax,
                          //           premiumDiscount: goldPremium,
                          //           totalCharges: totalChargeBeforeGoldPrice,
                          //           payableGrandTotal: grandTotal,
                          //         ),
                          //       ),
                          //     );
                          //   },
                          // ),

                          // LoaderButton(
                          //   title: "Buy Now",
                          //   onTap: () async {
                          //     double walletBalance = double.tryParse(
                          //             walletExists?.moneyBalance?.toString() ?? "0") ??
                          //         0.0;
                          //     double walletMetal = double.tryParse(
                          //             walletExists?.metalBalance?.toString() ?? "0") ??
                          //         0.0;
                          //
                          //     getLocator<Logger>().d(
                          //       "walletBalance: ${walletBalance.toStringAsFixed(3)} | walletMetal: ${walletMetal.toStringAsFixed(3)}",
                          //     );
                          //
                          //     // Small threshold to avoid floating-point precision issues
                          //     const double epsilon = 0.0001;
                          //
                          //     if ((walletBalance - 0.0).abs() < epsilon &&
                          //         (walletMetal - 0.0).abs() < epsilon) {
                          //       await showInsufficientBalancePopup();
                          //       return;
                          //     }
                          //
                          //     // Check if selected payment method has sufficient balance
                          //     bool isMoneyPayment = paymentMethod.toString() ==
                          //         PaymentMethod.money.toString();
                          //
                          //     if ((isMoneyPayment &&
                          //             walletBalance < totalGrandGoldPayableCharges) ||
                          //         (!isMoneyPayment &&
                          //             walletMetal < totalGrandGoldPayableCharges)) {
                          //       if (!context.mounted) return;
                          //       await showInsufficientBalancePopup();
                          //       return;
                          //     }
                          //
                          //     // Proceed to checkout
                          //     String paymentMethodString =
                          //         isMoneyPayment ? "Money" : "Metal";
                          //
                          //     var grandTotal = isMoneyPayment
                          //         ? totalGrandGoldPayableCharges
                          //         : gramBalanceEqual;
                          //
                          //     debugPrint("grandTotal: $grandTotal");
                          //
                          //     if (!context.mounted) return;
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => OrderCheckoutScreen(
                          //           product: widget.product,
                          //           paymentMethod: paymentMethodString,
                          //           productId: widget.product.id.toString(),
                          //           goldPrice: double.parse(widget.productPrice),
                          //           goldQuantity: double.parse(
                          //             goldQuantityController.text.toString().trim(),
                          //           ),
                          //           deliveryCharges: deliveryCharges,
                          //           makingCharges: makingCharges,
                          //           valueAtTax: valueAtTax,
                          //           premiumDiscount: goldPremium,
                          //           totalCharges: totalChargeBeforeGoldPrice,
                          //           //totalGrandGoldPayableCharges,
                          //           payableGrandTotal: grandTotal,
                          //         ),
                          //       ),
                          //     );
                          //   },
                          // ),
                          ConstPadding.sizeBoxWithHeight(height: 16),
                        ],
                      ).get16HorizontalPadding(),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// check and proceed
  // void checkAndProceed() async {
  //   // mainStateWatchProvider.getHomeFeedResponse.payload!.walletExists!;
  //
  //   double walletBalance =
  //       double.tryParse(widget.walletExists.moneyBalance?.toString() ?? "0") ??
  //           0.0;
  //   double walletMetal =
  //       double.tryParse(widget.walletExists.metalBalance?.toString() ?? "0") ??
  //           0.0;
  //
  //   getLocator<Logger>().d(
  //     "walletBalance: ${walletBalance.toStringAsFixed(3)} | walletMetal: ${walletMetal.toStringAsFixed(3)}",
  //   );
  //
  //   const double epsilon =
  //       0.0001; // Small threshold to avoid floating-point precision issues
  //
  //   if ((walletBalance - 0.0).abs() < epsilon &&
  //       (walletMetal - 0.0).abs() < epsilon) {
  //     await showInsufficientBalancePopup();
  //     return;
  //   }
  //
  //   // Check if selected payment method has sufficient balance
  //   bool isMoneyPayment =
  //       paymentMethod.toString() == PaymentMethod.money.toString();
  //
  //   if ((isMoneyPayment && walletBalance < totalGoldPayableCharges) ||
  //       (!isMoneyPayment && walletMetal < totalGoldPayableCharges)) {
  //     if (!context.mounted) return;
  //     await showInsufficientBalancePopup();
  //     return;
  //   }
  //
  //   // Proceed to checkout
  //   String paymentMethodString = isMoneyPayment ? "Money" : "Metal";
  //
  //   if (!context.mounted) return;
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => OrderCheckoutScreen(
  //         product: widget.product,
  //         productId: widget.product.id.toString(),
  //         deliveryCharges: deliveryCharges,
  //         goldPrice: goldPrice,
  //         goldQuantity: goldItemQuantity,
  //         totalGoldPayableAmount: totalGoldPayablePrice,
  //         paymentMethod: paymentMethodString,
  //       ),
  //     ),
  //   );
  // }

  // Helper function to show the insufficient balance popup
  Future<void> showInsufficientBalancePopup() async {
    if (!context.mounted) return;
    await genericPopUpWidget(
      context: context,
      heading: AppLocalizations.of(
        context,
      )!.invest_insufficient_balance_title, //"Insufficient Balance",
      subtitle: AppLocalizations.of(
        context,
      )!.add_fund_to_buy, //"Please add funds into your account to buy gold.",
      noButtonTitle: AppLocalizations.of(context)!.close, //"Close",
      yesButtonTitle: AppLocalizations.of(
        context,
      )!.dep_method_header, //"Add Funds",
      isLoadingState: false,
      onNoPress: () => Navigator.pop(context),
      onYesPress: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddFundScreen(),
          ),
        ).then((onValue) {});
      },
      // Handle add funds action
    );
  }

  Future<void> showInsufficientBalancePopupforDemo() async {
    if (!context.mounted) return;
    await genericPopUpWidget(
      context: context,
      heading: AppLocalizations.of(
        context,
      )!.insufficient_demo_balance, //"Insufficient Demo Balance",
      subtitle: AppLocalizations.of(
        context,
      )!.demo_balance_message, //"Your demo balance is insufficient. Funds are provided only once and cannot be replenished. Please invest within your balance, switch to a real account, or create a new demo account.",
      noButtonTitle: AppLocalizations.of(context)!.close, //"Close",
      yesButtonTitle: AppLocalizations.of(
        context,
      )!.upgrade_real_account_now, //"Upgrade Now",
      isLoadingState: false,
      onNoPress: () => Navigator.pop(context),
      onYesPress: () async {
        Navigator.pop(context);
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingScreen(),
          ),
        );
      },
    );
  }
}
