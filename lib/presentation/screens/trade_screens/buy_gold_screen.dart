import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/core/decimal_text_input_formatter.dart';
import 'package:baghdad_bullion_house/core/kyc/kyc_home_navigation.dart';
import 'package:baghdad_bullion_house/data/data_sources/local_database/local_database.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/email_verify_code_screen.dart';
import 'package:baghdad_bullion_house/presentation/screens/fund_screens/add_fund_screen.dart';
import 'package:baghdad_bullion_house/presentation/screens/setting_screens/setting_screen.dart';
import 'package:baghdad_bullion_house/presentation/sharedProviders/providers/trade_provider/trade_provider.dart';
import 'package:baghdad_bullion_house/presentation/widgets/input_formater.dart';
import 'package:baghdad_bullion_house/presentation/widgets/widget_export.dart';

import '../../../l10n/app_localizations.dart';
import '../../sharedProviders/providers/home_provider.dart';
import '../../sharedProviders/providers/sseGoldPriceProvider/sse_gold_price_provider.dart';

class BuyGoldScreen extends ConsumerStatefulWidget {
  const BuyGoldScreen({super.key});

  @override
  ConsumerState<BuyGoldScreen> createState() => _BuyGoldScreenState();
}

class _BuyGoldScreenState extends ConsumerState<BuyGoldScreen> {
  bool isBuyAtPriceStatus = false;
  final buyAtPriceController = TextEditingController();
  final userInputController = TextEditingController();

  String calculatedValue = '0.00';
  double buyingPriceInOneGram = 0.00;

  final _keyForm = GlobalKey<FormState>();
  final _focusNode = FocusNode();
  final _focusBuyAtPrice = FocusNode();
  Timer? _debounce;
  bool _isValidAmount = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(homeProvider.notifier)
          .getHomeFeed(
            context: context,
            showLoading: false,
          );
    });
    userInputController.addListener(_debouncedUpdateCalculation);
    buyAtPriceController.addListener(_debouncedUpdateCalculation);
  }

  void _debouncedUpdateCalculation() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _updateCalculation);
  }

  void _updateCalculation() {
    final goldPriceState = ref.read(goldPriceProvider);

    goldPriceState.whenData((data) {
      final oneGramIQDPrice = data.oneGramBuyingPriceInIQD;

      // Get user input for grams
      final inputValue =
          double.tryParse(userInputController.text.trim()) ?? 0.0;

      // Determine which price to use for calculation
      double priceToUse = oneGramIQDPrice;

      if (isBuyAtPriceStatus && buyAtPriceController.text.isNotEmpty) {
        final buyAtPrice = double.tryParse(buyAtPriceController.text.trim());
        if (buyAtPrice != null && buyAtPrice > 0) {
          priceToUse = buyAtPrice;
        }
      }

      // Update the UI
      if (mounted) {
        setState(() {
          calculatedValue = (inputValue * priceToUse).toStringAsFixed(3);
          buyingPriceInOneGram = oneGramIQDPrice;
        });
      }
    });
  }

  String _formatIqd(String value) {
    final parsed = double.tryParse(value) ?? 0.0;
    return CommonService.roundingFormatIqdCurrency(parsed);
  }

  static const double _marketPriceTol = 0.01;

  /// True when target-buy mode and entered price is empty, invalid, or above market.
  bool _buyTargetAboveMarket(double liveBuyingPerGram) {
    final t = double.tryParse(buyAtPriceController.text.trim());
    if (t == null || t <= 0) return true;
    return t > liveBuyingPerGram + _marketPriceTol;
  }

  @override
  void dispose() {
    buyAtPriceController.dispose();
    userInputController.dispose();
    _focusNode.dispose();
    _focusBuyAtPrice.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tradeStateWatchProvider = ref.watch(tradeProvider);
    final mainStateWatchProvider = ref.watch(homeProvider);
    final goldPriceState = ref.watch(goldPriceProvider);
    final buyTargetInvalid =
        isBuyAtPriceStatus &&
        goldPriceState.maybeWhen(
          data: (data) => _buyTargetAboveMarket(data.oneGramBuyingPriceInIQD),
          orElse: () => false,
        );
    ref.listen(goldPriceProvider, (previous, next) {
      _updateCalculation();
    });
    return Scaffold(
      backgroundColor: Color(0xff171919),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color(0xff171919),
        elevation: 0,
        title: Text(
          l10n.buy_gold,
          style: AppFonts.text(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          _buildTradeTypeDropdown(),
          const SizedBox(width: 12),
        ],
      ),

      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Form(
          key: _keyForm,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Market / Target Price Selector
                  const SizedBox(height: 30),

                  // Gram Input Section
                  Text(
                    l10n.amount,
                    style: AppFonts.text(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    l10n.buy_gold_grams_subtitle,
                    style: AppFonts.text(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 15),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      IntrinsicWidth(
                        child: TextFormField(
                          controller: userInputController,
                          focusNode: _focusNode,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          style: AppFonts.text(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: "1.00",
                            hintStyle: const TextStyle(color: Colors.white24),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            //errorText: _isValidAmount ? null : 'Amount must be greater than zero', // 👈 Show error if invalid
                          ),
                          inputFormatters: [
                            DecimalAmountInputFormatter(
                              maxDigits: 4,
                            ),
                          ],
                          onChanged: (value) {
                            // Validate on each change
                            final numValue = double.tryParse(value) ?? 0;
                            setState(() {
                              _isValidAmount = numValue > 0 && value.isNotEmpty;
                            });
                          },
                        ),
                      ),
                      //const SizedBox(width: 5),
                      // Text(
                      //   l10n.grams_unit_lowercase,
                      //   style: AppFonts.text(
                      //     color: Colors.white54,
                      //     fontSize: 20,
                      //   ),
                      // ),
                      Text(
                        (() {
                          final value =
                              double.tryParse(
                                userInputController.text.trim(),
                              ) ??
                              0;

                          return value > 1
                              ? l10n
                                    .grams_plural_lowercase //grams_unit_lowercase
                              : l10n.grams_unit_lowercase;
                        })(),
                        style: AppFonts.text(
                          color: Colors.white54,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    l10n.buy_gold_approx_total(_formatIqd(calculatedValue)),
                    style: AppFonts.text(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  // Max grams you can buy (based on IQD balance)
                  goldPriceState.when(
                    data: (data) {
                      final walletBalance =
                          double.tryParse(
                            mainStateWatchProvider
                                    .getHomeFeedResponse
                                    .payload
                                    ?.walletExists
                                    ?.moneyBalance
                                    ?.toString() ??
                                '0',
                          ) ??
                          0.0;
                      final pricePerGram =
                          isBuyAtPriceStatus &&
                              buyAtPriceController.text.isNotEmpty
                          ? (double.tryParse(
                                  buyAtPriceController.text.trim(),
                                ) ??
                                0.0)
                          : data.oneGramBuyingPriceInIQD;
                      final maxGrams = pricePerGram > 0
                          ? (walletBalance / pricePerGram)
                          : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "${l10n.max_grams_note} ${CommonService.formatGramForDisplay(maxGrams)}",
                          style: AppFonts.text(
                            color: Colors.white54,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 35),

                  // Current Market Price Display
                  _buildPriceCard(context, goldPriceState),

                  const SizedBox(height: 25),

                  // Conditional Target Price Input
                  if (isBuyAtPriceStatus) ...[
                    Text(
                      l10n.invest_target_price_per_gram,
                      style: AppFonts.text(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTargetPriceInput(context),
                    const SizedBox(height: 10),
                    Text(
                      l10n.buy_order_executes_at_iqd(
                        buyAtPriceController.text.isEmpty
                            ? '0'
                            : _formatIqd(buyAtPriceController.text),
                      ),
                      style: AppFonts.text(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    goldPriceState.when(
                      data: (data) {
                        if (!_buyTargetAboveMarket(
                          data.oneGramBuyingPriceInIQD,
                        )) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            l10n.invest_price_less_than_buying,
                            style: AppFonts.text(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],

                  // const Spacer(),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AbsorbPointer(
                      absorbing:
                          !_isValidAmount ||
                          buyTargetInvalid ||
                          (goldPriceState.value?.oneGramBuyingPriceInIQD ??
                                  0) <=
                              0,
                      child: Opacity(
                        opacity:
                            _isValidAmount &&
                                !buyTargetInvalid &&
                                (goldPriceState
                                            .value
                                            ?.oneGramBuyingPriceInIQD ??
                                        0) >
                                    0
                            ? 1.0
                            : 0.5,
                        child: LoaderButton(
                          title: l10n.buy_gold,
                          isLoadingState: tradeStateWatchProvider.isButtonState,
                          onTap: () => _onTradeButtonTap(
                            mainStateWatchProvider,
                            tradeStateWatchProvider,
                          ),
                        ),
                      ),
                    ),
                  ),
                  //const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceCard(BuildContext context, AsyncValue goldPriceState) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF262929),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.current_market_price,
                style: AppFonts.text(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 4),
              goldPriceState.when(
                data: (data) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.price_iqd_per_gram(
                        CommonService.formatIQDForDisplay(
                          data.oneGramBuyingPriceInIQD,
                        ),
                      ),
                      style: AppFonts.text(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.ounce_price_iqd(
                        CommonService.formatIQDForDisplay(
                          data.oneOunceBuyingPriceInIQD,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                loading: () => const SizedBox(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, __) => Text(
                  l10n.error_loading_price,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
          goldPriceState.when(
            data: (data) => Container(
              //padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_upward,
                    size: 12,
                    color: Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.high_price_badge(
                      CommonService.formatIQDForDisplay(
                        data.lastHighBuyingPrice,
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeTypeDropdown() {
    return PopupMenuButton<bool>(
      tooltip: '',
      offset: const Offset(0, 40),
      color: const Color(0xFF1C1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (value) {
        setState(() {
          isBuyAtPriceStatus = value;
          _updateCalculation();
        });
      },
      itemBuilder: (menuContext) {
        final l10n = AppLocalizations.of(menuContext)!;
        return [
          _buildPopupItem(
            title: l10n.trade_at_market_price,
            value: false,
            isSelected: !isBuyAtPriceStatus,
          ),
          _buildPopupItem(
            title: l10n.invest_target_price_menu,
            value: true,
            isSelected: isBuyAtPriceStatus,
          ),
        ];
      },
      child: Builder(
        builder: (ctx) {
          final l10n = AppLocalizations.of(ctx)!;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Text(
                  isBuyAtPriceStatus
                      ? l10n.invest_target_price_menu
                      : l10n.invest_market_price_short,
                  style: AppFonts.text(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white70,
                  size: 18,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PopupMenuItem<bool> _buildPopupItem({
    required String title,
    required bool value,
    required bool isSelected,
  }) {
    return PopupMenuItem<bool>(
      value: value,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppFonts.text(
                color: Colors.white,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          if (isSelected)
            const Icon(Icons.check, color: Colors.green, size: 18),
        ],
      ),
    );
  }

  Widget _buildTargetPriceInput(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: buyAtPriceController,
      focusNode: _focusBuyAtPrice,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF121212),
        hintText: l10n.target_price_hint_example,
        hintStyle: const TextStyle(color: Colors.white24),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        RoundedAmountInputFormatter(maxDigits: 6),
        //AmountInputFormatter(maxDigits: 6,),
      ],
    );
  }

  /// ALL ORIGINAL BUSINESS LOGIC INTEGRATED BELOW
  Future<void> _onTradeButtonTap(
    dynamic mainStateWatchProvider,
    dynamic tradeStateWatchProvider,
  ) async {
    final liveBuyingPriceIqd =
        ref.read(goldPriceProvider).value?.oneGramBuyingPriceInIQD ?? 0.0;
    if (liveBuyingPriceIqd <= 0) {
      if (!context.mounted) return;
      Toasts.getErrorToast(
        text: AppLocalizations.of(context)!.error_loading_price,
        gravity: ToastGravity.TOP,
      );
      return;
    }

    // 1. Email Verification Check
    if (!mainStateWatchProvider.isEmailVerified) {
      await genericPopUpWidget(
        isLoadingState: false,
        context: context,
        heading: AppLocalizations.of(context)!.email_verification_required,
        subtitle: AppLocalizations.of(context)!.email_verification_message,
        noButtonTitle: AppLocalizations.of(context)!.not_now,
        yesButtonTitle: AppLocalizations.of(context)!.verify_now,
        onNoPress: () => Navigator.pop(context),
        onYesPress: () async {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmailVerifyCodeScreen(
                email: mainStateWatchProvider.userEmail,
              ),
            ),
          );
        },
      );
      return;
    }

    final isDemo = await LocalDatabase.instance.getIsDemo() ?? false;
    if (!context.mounted) return;

    // 2. Profile verification check (always use live home-feed payload)
    final payload = mainStateWatchProvider.getHomeFeedResponse.payload;
    if (!isDemo && KycHomeNavigation.blocksVerifiedActions(payload)) {
      await KycHomeNavigation.showBlockedActionPopup(
        context,
        payload: payload,
      );
      return;
    }

    // 3. Balance Checks
    final walletBalance =
        double.tryParse(
          mainStateWatchProvider
                  .getHomeFeedResponse
                  .payload
                  ?.walletExists
                  ?.moneyBalance
                  ?.toString() ??
              '0',
        ) ??
        0.0;
    final inputAmount = double.tryParse(calculatedValue) ?? 0.0;
    const tolerance = 0.01;

    if (isBuyAtPriceStatus) {
      final targetBuy =
          double.tryParse(buyAtPriceController.text.trim()) ?? 0.0;
      if (targetBuy > liveBuyingPriceIqd + tolerance) {
        Toasts.getErrorToast(
          text: AppLocalizations.of(context)!.invest_price_less_than_buying,
          gravity: ToastGravity.TOP,
        );
        return;
      }
    }

    // Insufficient Real Balance
    if (!isDemo && (walletBalance + tolerance < inputAmount)) {
      await genericPopUpWidget(
        context: context,
        heading: AppLocalizations.of(context)!.insufficient_balance,
        subtitle: AppLocalizations.of(context)!.insufficient_balance_message(
          CommonService.formatIQDForDisplay(walletBalance),
          CommonService.formatIQDForDisplay(inputAmount),
        ),
        noButtonTitle: AppLocalizations.of(context)!.close,
        yesButtonTitle: AppLocalizations.of(context)!.add_funds,
        isLoadingState: false,
        onNoPress: () => Navigator.pop(context),
        onYesPress: () async {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFundScreen()),
          );
        },
      );
      return;
    }

    // Insufficient Demo Balance
    if (isDemo && (walletBalance + tolerance < inputAmount)) {
      await genericPopUpWidget(
        context: context,
        heading: AppLocalizations.of(context)!.insufficient_demo_balance,
        subtitle: AppLocalizations.of(context)!.demo_balance_message,
        noButtonTitle: AppLocalizations.of(context)!.close,
        yesButtonTitle: AppLocalizations.of(context)!.upgrade_now,
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
      return;
    }

    // 5. Final Confirmation and Execution
    if (userInputController.text.trim().isEmpty) {
      Toasts.getErrorToast(
        text: AppLocalizations.of(context)!.please_add_grams,
        gravity: ToastGravity.TOP,
      );
      return;
    }

    if (isBuyAtPriceStatus &&
        (buyAtPriceController.text.isEmpty ||
            (double.tryParse(buyAtPriceController.text) ?? 0) <= 0)) {
      Toasts.getErrorToast(
        text: AppLocalizations.of(context)!.please_enter_valid_price,
        gravity: ToastGravity.TOP,
      );
      return;
    }
    final rawPrice = num.tryParse(buyAtPriceController.text.trim()) ?? 0;

    final roundedPrice = num.parse(
      CommonService.roundingFormatIqdCurrency(
        rawPrice,
        useArabic: false,
      ).replaceAll(',', ''),
    );
    await showConfirmTradeDialog(
      context: context,
      isLimitOrder: isBuyAtPriceStatus,
      amountGrams: userInputController.text.trim(),
      targetPrice: isBuyAtPriceStatus
          ? _formatIqd(roundedPrice.toString()) // ✅ use rounded
          : CommonService.formatIQDForDisplay(buyingPriceInOneGram),
      totalCost: _formatIqd(calculatedValue),
      showCountdownTimer: !isBuyAtPriceStatus,
      limitBuyPricePerGram: isBuyAtPriceStatus
          ? roundedPrice
                .toDouble() // ✅ use rounded
          : null,
      onConfirm: () async {
        await ref
            .read(tradeProvider.notifier)
            .userCanBuyGold(
              context: context,
              tradeMoney: num.tryParse(calculatedValue) ?? 0,
              tradeMetal: num.tryParse(userInputController.text.trim()) ?? 0,
              buyAtPriceStatus: isBuyAtPriceStatus,
              buyAtPrice: isBuyAtPriceStatus
                  ? roundedPrice // ✅ use rounded here
                  : null,
              buyingPrice: buyingPriceInOneGram,
            );
      },
    );

    // Open Confirmation Dialog
    // await showConfirmTradeDialog(
    //   context: context,
    //   isLimitOrder: isBuyAtPriceStatus,
    //   amountGrams: userInputController.text.trim(),
    //   targetPrice: isBuyAtPriceStatus
    //       ? _formatIqd(buyAtPriceController.text)
    //       : CommonService.formatIQDForDisplay(buyingPriceInOneGram),
    //   totalCost: _formatIqd(calculatedValue),
    //   showCountdownTimer: !isBuyAtPriceStatus,
    //   limitBuyPricePerGram: isBuyAtPriceStatus
    //       ? double.tryParse(buyAtPriceController.text.trim())
    //       : null,
    //   onConfirm: () async {
    //     await ref
    //         .read(tradeProvider.notifier)
    //         .userCanBuyGold(
    //           context: context,
    //           tradeMoney: num.tryParse(calculatedValue) ?? 0,
    //           tradeMetal: num.tryParse(userInputController.text.trim()) ?? 0,
    //           buyAtPriceStatus: isBuyAtPriceStatus,
    //           buyAtPrice: isBuyAtPriceStatus
    //               ? num.tryParse(buyAtPriceController.text)
    //               : null,
    //           buyingPrice: buyingPriceInOneGram,
    //         );
    //   },
    // );
  }
}
