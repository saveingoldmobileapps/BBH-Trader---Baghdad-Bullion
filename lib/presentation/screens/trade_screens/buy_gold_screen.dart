import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/core/decimal_text_input_formatter.dart';
import 'package:saveingold_fzco/data/data_sources/local_database/local_database.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/auth_kyc_screens/kyc_first_step_screen.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/auth_kyc_screens/kyc_second_step_screen.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/email_verify_code_screen.dart';
import 'package:saveingold_fzco/presentation/screens/fund_screens/add_fund_screen.dart';
import 'package:saveingold_fzco/presentation/screens/setting_screens/setting_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/trade_provider/trade_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/input_formater.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

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
    return CommonService.formatIQDForDisplay(parsed);
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
          style: GoogleFonts.inter(
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
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    l10n.buy_gold_grams_subtitle,
                    style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
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
                          style: GoogleFonts.inter(
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
                            AmountInputFormatter(maxDigits: 4, decimalRange: 3),
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
                      const SizedBox(width: 10),
                      Text(
                        l10n.grams_unit_lowercase,
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    l10n.buy_gold_approx_total(_formatIqd(calculatedValue)),
                    style: GoogleFonts.inter(
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
                          "${l10n.max_grams_note} ${maxGrams.toStringAsFixed(3)}",
                          style: GoogleFonts.inter(
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
                      style: GoogleFonts.inter(
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
                      style: GoogleFonts.inter(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],

                  // const Spacer(),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AbsorbPointer(
                      absorbing: !_isValidAmount ||
                          (goldPriceState.value?.oneGramBuyingPriceInIQD ??
                                  0) <=
                              0,
                      child: Opacity(
                        opacity: _isValidAmount &&
                                (goldPriceState.value?.oneGramBuyingPriceInIQD ??
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
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
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
                      style: GoogleFonts.inter(
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
                      CommonService.formatIQDForDisplay(data.lastHighBuyingPrice),
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
              style: GoogleFonts.inter(
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
              style: GoogleFonts.inter(
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
        AmountInputFormatter(maxDigits: 6, decimalRange: 3),
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

    // 2. Residency Verification Check
    if (!isDemo &&
        mainStateWatchProvider.isEmailVerified &&
        !mainStateWatchProvider.isBasicUserVerified) {
      await genericPopUpWidget(
        isLoadingState: false,
        context: context,
        heading: AppLocalizations.of(context)!.residency_verification_required,
        subtitle: AppLocalizations.of(context)!.residency_verification_message,
        noButtonTitle: AppLocalizations.of(context)!.not_now,
        yesButtonTitle: AppLocalizations.of(context)!.verify_now,
        onNoPress: () => Navigator.pop(context),
        onYesPress: () async {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KycFirstStepScreen()),
          );
        },
      );
      return;
    }

    // 3. KYC Verification Check
    if (!isDemo &&
        mainStateWatchProvider.isEmailVerified &&
        mainStateWatchProvider.isBasicUserVerified &&
        !mainStateWatchProvider.isUserKYCVerified) {
      await genericPopUpWidget(
        isLoadingState: false,
        context: context,
        heading: AppLocalizations.of(context)!.kyc_verification_required,
        subtitle: AppLocalizations.of(context)!.kyc_verification_message,
        noButtonTitle: AppLocalizations.of(context)!.later,
        yesButtonTitle: AppLocalizations.of(context)!.proceed,
        onNoPress: () => Navigator.pop(context),
        onYesPress: () async {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const KycSecondStepScreen(),
            ),
          );
        },
      );
      return;
    }

    // 4. Balance Checks
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

    // Open Confirmation Dialog
    await showConfirmTradeDialog(
      context: context,
      isLimitOrder: isBuyAtPriceStatus,
      amountGrams: userInputController.text.trim(),
      targetPrice: isBuyAtPriceStatus
          ? _formatIqd(buyAtPriceController.text)
          : CommonService.formatIQDForDisplay(buyingPriceInOneGram),
      totalCost: _formatIqd(calculatedValue),
      onConfirm: () async {
        await ref
            .read(tradeProvider.notifier)
            .userCanBuyGold(
              context: context,
              tradeMoney: num.tryParse(calculatedValue) ?? 0,
              tradeMetal: num.tryParse(userInputController.text.trim()) ?? 0,
              buyAtPriceStatus: isBuyAtPriceStatus,
              buyAtPrice: isBuyAtPriceStatus
                  ? num.tryParse(buyAtPriceController.text)
                  : null,
              buyingPrice: buyingPriceInOneGram,
            );
      },
    );

    // await genericPopUpLivePriceWidget(
    //   autoCloseAfterSeconds: 5,
    //   context: context,
    //   heading: AppLocalizations.of(context)!.confirmation,
    //   subtitle: isBuyAtPriceStatus
    //       ? AppLocalizations.of(context)!.place_order_confirm
    //       : AppLocalizations.of(
    //           context,
    //         )!.invest_confirmation_message(userInputController.text.trim()),
    //   noButtonTitle: AppLocalizations.of(context)!.cancel,
    //   yesButtonTitle: isBuyAtPriceStatus
    //       ? AppLocalizations.of(context)!.place_order
    //       : AppLocalizations.of(context)!.confirm_purchase,
    //   isLoadingState: tradeStateWatchProvider.isButtonState,
    //   onNoPress: () => Navigator.pop(context),
    //   onYesPress: () async {
    //     Navigator.pop(context);
    //     await ref
    //         .read(tradeProvider.notifier)
    //         .userCanBuyGold(
    //           context: context,
    //           tradeMoney: num.tryParse(calculatedValue) ?? 0.0,
    //           tradeMetal: num.tryParse(userInputController.text.trim()) ?? 0.0,
    //           buyAtPriceStatus: isBuyAtPriceStatus,
    //           buyAtPrice: isBuyAtPriceStatus
    //               ? num.tryParse(buyAtPriceController.text.trim())
    //               : null,
    //           buyingPrice: buyingPriceInOneGram,
    //         );
    //     userInputController.clear();
    //     buyAtPriceController.clear();
    //     setState(() {
    //       calculatedValue = '0.00';
    //       isBuyAtPriceStatus = false;
    //     });
    //   },
    //   livePriceWidget: Consumer(
    //     builder: (context, ref, _) {
    //       final goldPriceState = ref.watch(goldPriceProvider);
    //       return goldPriceState.when(
    //         data: (data) => GetGenericText(
    //           text:
    //               '${AppLocalizations.of(context)!.buy_gold_pop} ${data.oneGramBuyingPriceInIQD.toStringAsFixed(2)} ${AppLocalizations.of(context)!.idq_currency}',
    //           fontSize: 18,
    //           fontWeight: FontWeight.w600,
    //           color: AppColors.primaryGold500,
    //           textAlign: TextAlign.center,
    //         ).getChildCenter(),
    //         loading: () => const CircularProgressIndicator(),
    //         error: (_, __) => const Text("Error"),
    //       );
    //     },
    //   ),
    // );
  }
}
