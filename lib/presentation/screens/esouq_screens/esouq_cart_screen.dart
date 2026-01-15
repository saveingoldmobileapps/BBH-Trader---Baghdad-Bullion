import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/data_sources/local_database/local_database.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/fund_screens/add_fund_screen.dart';
import 'package:saveingold_fzco/presentation/screens/setting_screens/setting_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/gram_provider/gram_provider.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/home_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/loader_button.dart';
import 'package:saveingold_fzco/presentation/widgets/pop_up_widget.dart';
import 'package:saveingold_fzco/presentation/widgets/search_check_dropdown.dart';

import '../../../data/models/esouq_model/GetAllProductResponse.dart';
import '../../../data/models/home_models/GetHomeFeedResponse.dart';
import '../../sharedProviders/providers/sseGoldPriceProvider/sse_gold_price_provider.dart';
import '../../widgets/shimmers/shimmer_loader.dart';
import 'order_checkout_screen.dart';

enum PaymentMethod { metal, money }

class EsouqCartScreen extends ConsumerStatefulWidget {
  final AllProducts product;
  final String productPrice;
  final String oneGramPriceInIQD;

  const EsouqCartScreen({
    required this.product,
    required this.productPrice,
    required this.oneGramPriceInIQD,
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
    final oneGramBuyingPriceInIQD =
        goldPriceState.value?.oneGramBuyingPriceInIQD ?? 0.0;
    setState(() {
      final quantity =
          double.tryParse(goldQuantityController.text.trim()) ?? 1.0;
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
      final fixPricingT4b = oneGramBuyingPriceInIQD;

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

      goldPremium = premiumDiscount * quantity;
      makingCharges = totalMakingCharges;
      deliveryCharges = deliveryChargesValue;
      valueAtTax = totalVatTax;
      gramBalanceEqual = weightFactor * quantity;
    });
  }

  double _extractNumericValue(String? value) {
    if (value == null) return 0.0;
    final numeric = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(numeric) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    final gramState = ref.watch(gramProvider);
    final goldPriceState = ref.watch(goldPriceProvider);
    final mainStateWatchProvider = ref.watch(homeProvider);

    if (goldPriceState.hasValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateTotal();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.greyScale1000,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  mainStateWatchProvider.loadingState == LoadingState.loading ||
                      gramState.loadingState == LoadingState.loading
                  ? const Center(child: ShimmerLoader(loop: 5))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Review order",
                              style: TextStyle(
                                color: const Color(0xFFF2F2F7),
                                fontSize: sizes!.isPhone ? 32 : 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Item Container
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xff262929),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          widget.product.imageUrl?.isNotEmpty ==
                                              true
                                          ? widget.product.imageUrl!.first
                                          : "",
                                      height: 60,
                                      width: 60,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${widget.product.productName?.toUpperCase()}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "IQD ${finalGoldPrice.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            color: Color(0xFFBBA473),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          double current =
                                              double.tryParse(
                                                goldQuantityController.text,
                                              ) ??
                                              1;
                                          if (current > 1) {
                                            goldQuantityController.text =
                                                (current - 1)
                                                    .toInt()
                                                    .toString();
                                            _calculateTotal();
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      Text(
                                        goldQuantityController.text,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          double current =
                                              double.tryParse(
                                                goldQuantityController.text,
                                              ) ??
                                              1;
                                          goldQuantityController.text =
                                              (current + 1).toInt().toString();
                                          _calculateTotal();
                                        },
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Charges Container
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xff262929),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Charges",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildChargeRow("Premium", goldPremium),
                                  _buildChargeRow("Making", makingCharges),
                                  _buildChargeRow("VAT", valueAtTax),
                                  _buildChargeRow("Delivery", deliveryCharges),
                                  const Divider(
                                    color: Colors.white10,
                                    height: 32,
                                  ),
                                  _buildChargeRow(
                                    "Total charges",
                                    totalChargeBeforeGoldPrice,
                                    isTotal: true,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Payment Method
                            _buildPaymentMethodDropdown(context, gramState),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
            ),
            // Fixed Bottom Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              decoration: const BoxDecoration(
                color: Color(0xff262929),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Grant total",
                        style: TextStyle(
                          color: Color(0xFFD1D1D6),
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "IQD ${totalGrandGoldPayableCharges.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LoaderButton(
                    title: "Go to checkout",
                    onTap: () async => await _handleBuyNow(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChargeRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFFD1D1D6),
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            "IQD ${value.toStringAsFixed(2)}",
            style: TextStyle(
              color: Colors.white,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodDropdown(BuildContext context, dynamic gramState) {
    final hasGramDeals =
        gramState.gramApiResponseModel.payload?.any(
          (deal) => deal.tradeType == 'Buy' && deal.tradeStatus == 'Opened',
        ) ??
        false;
    final dropdownItems = hasGramDeals ? ['Money', 'Metal'] : ['Money'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment Method",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          dropdownColor: const Color(0xFF1C1C1E),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1C1C1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          // initialValue: _selectedPaymentMethod,
          
          value: _selectedPaymentMethod,
          items: dropdownItems
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
        ),
        if (_selectedPaymentMethod == "Metal") ...[
          const SizedBox(height: 16),
          // Your existing SearchableWithCheckBox widget logic
          SearchableWithCheckBox(
            iconString: "assets/svg/arrow_down.svg",
            title: AppLocalizations.of(context)!.gift_select_gram,
            items:
                (gramState.gramApiResponseModel.payload as List?)
                    ?.where(
                      (deal) =>
                          deal.tradeType == 'Buy' &&
                          deal.tradeStatus == 'Opened',
                    )
                    .map<String>(
                      (deal) =>
                          "${deal.dealId} - ${deal.tradeMetal!.toStringAsFixed(2)}g gold",
                    )
                    .toList() ??
                [],
            label: AppLocalizations.of(context)!.gramDeal,
            hint: AppLocalizations.of(context)!.plz_choose_deal,
            gramBalanceEqual: gramBalanceEqual,
            selectedItems:
                selectedIds?.map((id) => id.toString()).toList() ?? [],
            onChanged: (List<String> selectedList) {
              // Your existing logic for updating selectedDealsData
            },
          ),
        ],
      ],
    );
  }

  Future<void> _handleBuyNow(BuildContext context) async {
    final quantityText = goldQuantityController.text.trim();
    final quantity = num.tryParse(quantityText);
    if (quantity == null || quantity <= 0) {
      Toasts.getErrorToast(text: AppLocalizations.of(context)!.valid_quantitty);
      return;
    }

    double walletBalance =
        double.tryParse(walletExists?.moneyBalance?.toString() ?? "0") ?? 0.0;
    double walletMetal =
        double.tryParse(walletExists?.metalBalance?.toString() ?? "0") ?? 0.0;
    const double epsilon = 0.0001;

    if (walletBalance.abs() < epsilon && walletMetal.abs() < epsilon) {
      await showInsufficientBalancePopup();
      return;
    }

    final isMoneyPayment = _selectedPaymentMethod == "Money";
    final isDemo = await LocalDatabase.instance.getIsDemo() ?? false;

    if (!isDemo &&
        ((isMoneyPayment && walletBalance < totalGrandGoldPayableCharges) ||
            (!isMoneyPayment && walletMetal < gramBalanceEqual))) {
      showInsufficientBalancePopup();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderCheckoutScreen(
          product: widget.product,
          paymentMethod: isMoneyPayment ? "Money" : "Metal",
          productId: widget.product.id.toString(),
          goldPrice: double.parse(widget.productPrice),
          goldQuantity: double.tryParse(goldQuantityController.text) ?? 0.0,
          deliveryCharges: deliveryCharges,
          makingCharges: makingCharges,
          valueAtTax: valueAtTax,
          premiumDiscount: goldPremium,
          totalCharges: totalChargeBeforeGoldPrice,
          grandPayableTotalGramOrMoney: isMoneyPayment
              ? totalGrandGoldPayableCharges
              : gramBalanceEqual,
          selectedPaymentMethod: _selectedPaymentMethod,
          selectedDealsData: selectedDealsData,
          currentGoldPrice:
              ref.read(goldPriceProvider).value?.oneGramBuyingPriceInIQD ?? 0.0,
        ),
      ),
    );
  }

  Future<void> showInsufficientBalancePopup() async {
    if (!context.mounted) return;
    await genericPopUpWidget(
      context: context,
      heading: AppLocalizations.of(context)!.invest_insufficient_balance_title,
      subtitle: AppLocalizations.of(context)!.add_fund_to_buy,
      noButtonTitle: AppLocalizations.of(context)!.close,
      yesButtonTitle: AppLocalizations.of(context)!.dep_method_header,
      isLoadingState: false,
      onNoPress: () => Navigator.pop(context),
      onYesPress: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddFundScreen()),
        );
      },
    );
  }

  Future<void> showInsufficientBalancePopupforDemo() async {
    if (!context.mounted) return;
    await genericPopUpWidget(
      context: context,
      heading: AppLocalizations.of(context)!.insufficient_demo_balance,
      subtitle: AppLocalizations.of(context)!.demo_balance_message,
      noButtonTitle: AppLocalizations.of(context)!.close,
      yesButtonTitle: AppLocalizations.of(context)!.upgrade_real_account_now,
      isLoadingState: false,
      onNoPress: () => Navigator.pop(context),
      onYesPress: () async {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingScreen()),
        );
      },
    );
  }
}
