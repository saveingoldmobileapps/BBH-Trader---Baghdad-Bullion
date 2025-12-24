import 'dart:async';

import 'package:flutter/material.dart';
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
import 'package:saveingold_fzco/presentation/widgets/live_price_container.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

import '../../../l10n/app_localizations.dart';
import '../../sharedProviders/providers/home_provider.dart';
import '../../sharedProviders/providers/sseGoldPriceProvider/sse_gold_price_provider.dart';
import '../main_home_screens/trade_screen.dart';

class BuyGoldScreen extends ConsumerStatefulWidget {
  const BuyGoldScreen({super.key});

  @override
  ConsumerState<BuyGoldScreen> createState() => _BuyGoldScreenState();
}

class _BuyGoldScreenState extends ConsumerState<BuyGoldScreen> {
  final TradeType tradeType = TradeType.buy;
  bool isBuyAtPriceStatus = false;
  final buyAtPriceController = TextEditingController();
  final userInputController = TextEditingController();
  bool isSwitchValue = true;

  // Constants
  // static const double _usdToAed = 3.674; // 1 USD to AED
  // static const double _gramsPerOunce = 31.10347; // 1 ounce in grams
  static const String _defaultValue = '0.00';

  // State variables
  String calculatedValue = _defaultValue;
  double buyingPriceInOneGram = 0.00;

  final _keyForm = GlobalKey<FormState>();
  final _focusNode = FocusNode(); // Add FocusNode
  final _focusBuyAtPrice = FocusNode(); // Add FocusNode

  Timer? _debounce; // For debouncing _updateCalculation

  @override
  void initState() {
    super.initState();

    ///check if home Provider is null recall api
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mainState = ref.read(homeProvider);

        ref
            .read(homeProvider.notifier)
            .getHomeFeed(
              context: context,
              showLoading: false,
            );

    });
    userInputController.addListener(_debouncedUpdateCalculation);
    buyAtPriceController.addListener(
      _debouncedUpdateCalculation,
    ); // Add listener for buyAtPrice
  }

  /// debouncing update calculation
  void _debouncedUpdateCalculation() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _updateCalculation);
  }

  // updating calculation
  void _updateCalculation() {
    final goldPriceState = ref.read(goldPriceProvider);
    //final mainState = ref.read(homeProvider);

    // final walletBalance =
    //     double.tryParse(
    //       mainState.getHomeFeedResponse.payload?.walletExists?.moneyBalance
    //               ?.toString() ??
    //           '0',
    //     ) ??
    //     0.0;

    goldPriceState.when(
      data: (data) {
        // final buyingPX = data.oneGramBuyingPriceInAED;
        //data.getGoldPriceResponse.prices?.last.mDBuyingPx ?? 0.0;
        // final oneGramAEDPrice = (buyingPX * _usdToAed) / _gramsPerOunce;

        final oneGramAEDPrice = data.oneGramBuyingPriceInAED;
        final inputValue =
            double.tryParse(userInputController.text.trim()) ?? 0.0;

        // Use buyAtPrice if enabled and valid, otherwise use current price
        double priceToUse = oneGramAEDPrice;
        if (isBuyAtPriceStatus && buyAtPriceController.text.isNotEmpty) {
          final buyAtPrice = double.tryParse(buyAtPriceController.text.trim());
          if (buyAtPrice != null && buyAtPrice > 0) {
            priceToUse = buyAtPrice;
          }
        }

        setState(() {
          calculatedValue = (inputValue * priceToUse).toStringAsFixed(2);
          buyingPriceInOneGram = oneGramAEDPrice;
        });
      },
      error: (error, stackTrace) {
        setState(() {
          calculatedValue = _defaultValue;
        });
      },
      loading: () {
        setState(() {
          calculatedValue = _defaultValue;
        });
      },
    );
  }

  @override
  void dispose() {
    userInputController.removeListener(_debouncedUpdateCalculation);
    buyAtPriceController.removeListener(_debouncedUpdateCalculation);
    buyAtPriceController.dispose();
    userInputController.dispose();
    _focusNode.dispose();
    _focusBuyAtPrice.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ref.invalidate(goldPriceProvider);
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        ref.invalidate(goldPriceProvider);
      }
    });
    final tradeStateWatchProvider = ref.watch(tradeProvider);
    final mainStateWatchProvider = ref.watch(homeProvider);

    /// for gold price
    //final goldPriceStateWatchProvider = ref.watch(goldPriceProvider);
    // debugPrint("buyGoldScreenRebuild");

    /// Get wallet balance with proper null safety
    // final walletBalance =
    //     double.tryParse(
    //       mainStateWatchProvider
    //               .getHomeFeedResponse
    //               .payload
    //               ?.walletExists
    //               ?.moneyBalance
    //               ?.toString() ??
    //           '0',
    //     ) ??
    //     0.0;

    // debugPrint("walletBalance: $walletBalance");

    return Form(
      key: _keyForm,
      child: GestureDetector(
        onTap: () {
          _focusNode.unfocus();
          _focusBuyAtPrice.unfocus();
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Selling Price Container
                LivePriceContainer(
                  title: AppLocalizations.of(context)!.selling_price,
                  isSelling: true,
                  todayHighLow: AppLocalizations.of(context)!.low,
                ),
                ConstPadding.sizeBoxWithWidth(width: 6),
                // Buying Price Container
                LivePriceContainer(
                  title: AppLocalizations.of(context)!.buying_price,
                  isSelling: false,
                  todayHighLow: AppLocalizations.of(context)!.high,
                ),
              ],
            ),
            ConstPadding.sizeBoxWithHeight(height: 16),
            _buildAmountPriceInputSection(),
            ConstPadding.sizeBoxWithHeight(height: 8),

            /// Maximum purchasable grams - Updated Widget
            Consumer(
              builder: (context, ref, child) {
                final goldPriceState = ref.watch(goldPriceProvider);
                final mainState = ref.watch(homeProvider);

                return goldPriceState
                    .when(
                      data: (data) {
                        final walletBalance =
                            double.tryParse(
                              mainState
                                      .getHomeFeedResponse
                                      .payload
                                      ?.walletExists
                                      ?.moneyBalance
                                      ?.toString() ??
                                  '0',
                            ) ??
                            0.0;
                        final double buyingPriceInOneGram =
                            data.oneGramBuyingPriceInAED;
                        final maxGrams = buyingPriceInOneGram > 0
                            ? walletBalance / buyingPriceInOneGram
                            : 0.0;

                        final message = walletBalance == 0
                            ? AppLocalizations.of(context)!.wallet_empty
                            : "${AppLocalizations.of(context)!.max_grams_note} ${maxGrams.toStringAsFixed(2)}"; //"Max grams you can buy: ${maxGrams.toStringAsFixed(2)}";
                        return GetGenericText(
                          text: message,
                          fontSize: sizes!.isPhone ? 11 : 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey3Color,
                        );
                      },
                      error: (error, stackTrace) => const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                    )
                    .getAlign();
              },
            ),

            /// Buy at price
            BuildSwitchOption(
              title: AppLocalizations.of(context)!.buy_at_price,
              value: isBuyAtPriceStatus,
              onChanged: (value) {
                setState(() {
                  isBuyAtPriceStatus = value;
                  _updateCalculation(); // Update calculation when switch is toggled
                });
              },
            ),

            /// buy at price status
            if (isBuyAtPriceStatus) ...[
              ConstPadding.sizeBoxWithHeight(height: 10),
              // CommonTextFormField(
              //   focusNode: _focusBuyAtPrice,
              //   title: "",
              //   hintText: AppLocalizations.of(context)!.per_gram_aed,
              //   labelText: AppLocalizations.of(context)!.buy_at_price,
              //   controller: buyAtPriceController,
              //   inputFormatters: [
              //     DecimalTextInputFormatter(decimalRange: 2),
              //     //LengthLimitingTextInputFormatter(15),
              //   ],

              //   textInputType: TextInputType.numberWithOptions(
              //     signed: true,
              //     decimal: true,
              //   ),
              //   validator: isBuyAtPriceStatus
              //       ? (value) {
              //           if (value!.isEmpty) {
              //             return AppLocalizations.of(context)!.please_enter_valid_amount;
              //           }
              //           return null;
              //         }
              //       : null,
              // ),
              CommonTextFormField(
                focusNode: _focusBuyAtPrice,
                title: "",
                hintText: AppLocalizations.of(context)!.per_gram_aed,
                labelText: AppLocalizations.of(context)!.buy_at_price,
                controller: buyAtPriceController,
                inputFormatters: [
                  DecimalTextInputFormatter(decimalRange: 2),
                  // LengthLimitingTextInputFormatter(15),
                ],
                textInputType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                validator: isBuyAtPriceStatus
                    ? (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!.please_enter_valid_amount;
                        }
                        final parsedValue = double.tryParse(value);
                        if (parsedValue == null || parsedValue <= 0) {
                          return AppLocalizations.of(
                            context,
                          )!.please_enter_valid_amount;
                        }
                        return null;
                      }
                    : null,
              ),
            ],
            ConstPadding.sizeBoxWithHeight(height: 16),

            /// Loader Button
            LoaderButton(
              title: AppLocalizations.of(context)!.buy_gold,
              isLoadingState: tradeStateWatchProvider.isButtonState,
              onTap: () async {
                ///If email not verified.
                if (!mainStateWatchProvider.isEmailVerified) {
                  await genericPopUpWidget(
                    isLoadingState: false,
                    context: context,
                    heading: AppLocalizations.of(
                      context,
                    )!.email_verification_required,
                    subtitle: AppLocalizations.of(
                      context,
                    )!.email_verification_message,
                    noButtonTitle: AppLocalizations.of(context)!.not_now,
                    yesButtonTitle: AppLocalizations.of(context)!.verify_now,
                    onNoPress: () async {
                      Navigator.pop(context);
                    },
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

                ///If email verified and residency not verified.
                ///

                final isDemo =
                    await LocalDatabase.instance.getIsDemo() ?? false;

                if (!context.mounted) return;
                if (!isDemo &&
                    mainStateWatchProvider.isEmailVerified &&
                    !mainStateWatchProvider.isBasicUserVerified) {
                  await genericPopUpWidget(
                    isLoadingState: false,
                    context: context,
                    heading: AppLocalizations.of(
                      context,
                    )!.residency_verification_required,
                    subtitle: AppLocalizations.of(
                      context,
                    )!.residency_verification_message,
                    noButtonTitle: AppLocalizations.of(context)!.not_now,
                    yesButtonTitle: AppLocalizations.of(context)!.verify_now,
                    onNoPress: () async {
                      Navigator.pop(context);
                    },
                    onYesPress: () async {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KycFirstStepScreen(),
                        ),
                      );
                    },
                  );
                  return;
                }

                ///if email and residency document verified and kyc not verified
                if (!isDemo &&
                    mainStateWatchProvider.isEmailVerified &&
                    mainStateWatchProvider.isBasicUserVerified &&
                    !mainStateWatchProvider.isUserKYCVerified) {
                  if (!context.mounted) return;
                  await genericPopUpWidget(
                    isLoadingState: false,
                    context: context,
                    heading: AppLocalizations.of(
                      context,
                    )!.kyc_verification_required,
                    subtitle: AppLocalizations.of(
                      context,
                    )!.kyc_verification_message,
                    noButtonTitle: AppLocalizations.of(context)!.later,
                    yesButtonTitle: AppLocalizations.of(context)!.proceed,
                    onNoPress: () async {
                      Navigator.pop(context);
                    },
                    onYesPress: () async {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KycSecondStepScreen(),
                        ),
                      );
                    },
                  );
                  return;
                }
                // Get wallet balance and input amount safely
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

                // Optional: Tolerance for floating-point errors
                const tolerance = 0.01;

                if (!isDemo && (walletBalance + tolerance < inputAmount)) {
                  await genericPopUpWidget(
                    context: context,
                    heading: AppLocalizations.of(context)!.insufficient_balance,
                    subtitle: AppLocalizations.of(context)!
                        .insufficient_balance_message(
                          walletBalance.toStringAsFixed(2),
                          inputAmount.toStringAsFixed(2),
                        ),

                    //"Your balance (AED ${walletBalance.toStringAsFixed(2)}) is less than the required amount (AED ${inputAmount.toStringAsFixed(2)}). Please add funds.",
                    noButtonTitle: AppLocalizations.of(context)!.close,
                    yesButtonTitle: AppLocalizations.of(context)!.add_funds,
                    isLoadingState: false,
                    onNoPress: () async {
                      _focusNode.unfocus();
                      _focusBuyAtPrice.unfocus();
                      Navigator.pop(context);
                    },
                    onYesPress: () async {
                      _focusNode.unfocus();
                      _focusBuyAtPrice.unfocus();
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddFundScreen(),
                        ),
                      );
                    },
                  );
                  return;
                }
                //if demo user and amount is less then navigate to the switching to real user
                if (isDemo && (walletBalance + tolerance < inputAmount)) {
                  await genericPopUpWidget(
                    context: context,
                    heading: AppLocalizations.of(
                      context,
                    )!.insufficient_demo_balance,
                    subtitle: AppLocalizations.of(
                      context,
                    )!.demo_balance_message,
                    noButtonTitle: AppLocalizations.of(context)!.close,
                    // "Close",
                    yesButtonTitle: AppLocalizations.of(context)!.upgrade_now,
                    // "Upgrade Now",
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
                  return;
                }

                ///if all verified, then navigate to add fund screen
                if (isBuyAtPriceStatus) {
                  final userInput = userInputController.text.trim();
                  final inputBuyAtPrice = buyAtPriceController.text.trim();
                  final buyAtPrice = double.tryParse(inputBuyAtPrice) ?? 0.0;

                  final checkUserBuyAtPrice = buyAtPrice < buyingPriceInOneGram;

                  // Validation for zero amount of gram
                  if (userInputController.text.trim().isEmpty) {
                    Toasts.getErrorToast(
                      gravity: ToastGravity.TOP,
                      text: AppLocalizations.of(context)!.please_add_grams,
                      // 'Please add grams amount.',
                      duration: const Duration(seconds: 55),
                    );
                    return;
                  }
                  if (userInput.isEmpty) {
                    Toasts.getErrorToast(
                      gravity: ToastGravity.TOP,
                      text: AppLocalizations.of(context)!.please_add_grams,
                      duration: const Duration(seconds: 2),
                    );
                    return;
                  }

                  if (inputBuyAtPrice.isEmpty || buyAtPrice <= 0) {
                    Toasts.getErrorToast(
                      gravity: ToastGravity.TOP,
                      text: AppLocalizations.of(
                        context,
                      )!.please_enter_valid_price,
                      duration: const Duration(seconds: 2),
                    );
                    return;
                  }

                  if (userInput.isNotEmpty &&
                      inputBuyAtPrice.isNotEmpty &&
                      checkUserBuyAtPrice) {
                    debugPrint("BuyGoldClicked");
                    _focusNode.unfocus();
                    _focusBuyAtPrice.unfocus();

                    // Ensure providers are in data state
                    final goldPriceState = ref.read(goldPriceProvider);
                    final mainState = ref.read(homeProvider);

                    if (goldPriceState is AsyncError ||
                        mainState is AsyncError) {
                      Toasts.getErrorToast(
                        gravity: ToastGravity.TOP,
                        text: AppLocalizations.of(
                          context,
                        )!.unable_to_fetch_data,
                        // 'Unable to fetch latest data. Please try again.',
                        duration: const Duration(seconds: 2),
                      );
                      return;
                    }

                    if (goldPriceState is AsyncLoading ||
                        mainState is AsyncLoading) {
                      Toasts.getSuccessToast(
                        gravity: ToastGravity.TOP,
                        text: AppLocalizations.of(context)!.data_loading,
                        //  'Data is loading. Please wait.',
                        duration: const Duration(seconds: 2),
                      );
                      return;
                    }

                    // Get wallet balance with proper null safety
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

                    // Validate calculatedValue
                    if (calculatedValue.isEmpty ||
                        calculatedValue == _defaultValue) {
                      Toasts.getErrorToast(
                        gravity: ToastGravity.TOP,
                        text: AppLocalizations.of(context)!.invalid_amount,

                        // 'Invalid amount. Please enter a valid value.',
                        duration: const Duration(seconds: 2),
                      );
                      return;
                    }

                    // Get input amount with validation
                    final inputAmount = double.tryParse(calculatedValue) ?? 0.0;

                    // Detailed logging
                    debugPrint(
                      "inputAmount: $inputAmount, walletBalance: $walletBalance, calculatedValue: $calculatedValue",
                    );

                    // Add tolerance for floating-point comparison
                    // const tolerance = 0.01;
                    // if (walletBalance < (inputAmount - tolerance)) {
                    //   // Generic popup widget for insufficient balance
                    //   await genericPopUpWidget(
                    //     context: context,
                    //     heading: "Insufficient Balance",
                    //     subtitle:
                    //         "Your balance ($walletBalance AED) is less than the required amount ($inputAmount AED). Please add funds.",
                    //     noButtonTitle: "Close",
                    //     yesButtonTitle: "Add Funds",
                    //     isLoadingState: false,
                    //     onNoPress: () async {
                    //       _focusNode.unfocus();
                    //       _focusBuyAtPrice.unfocus();
                    //       Navigator.pop(context);
                    //     },
                    //     onYesPress: () async {
                    //       _focusNode.unfocus();
                    //       _focusBuyAtPrice.unfocus();
                    //       Navigator.pop(context);
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => const AddFundScreen(),
                    //         ),
                    //       );
                    //     },
                    //   );
                    //   return;
                    // }

                    // Proceed with confirmation popup
                    await genericPopUpWidget(
                      context: context,

                      heading: AppLocalizations.of(context)!.confirmation,
                      //  "Confirmation",
                      subtitle: isBuyAtPriceStatus
                          ? AppLocalizations.of(context)!.place_order_confirm
                          // "Do you want to place this pending order?"
                          : AppLocalizations.of(
                              context,
                            )!.invest_confirmation_message(
                              userInputController.text.trim(),
                            ), //"Do you want to buy ${userInputController.text.trim()} grams of gold now?",
                      noButtonTitle: AppLocalizations.of(
                        context,
                      )!.cancel, //"Cancel",
                      yesButtonTitle: isBuyAtPriceStatus
                          ? AppLocalizations.of(context)!.place_order
                          // "Place Order"
                          : AppLocalizations.of(context)!.confirm_purchase,
                      //  "Confirm Purchase",
                      // heading: "Confirmation",
                      // subtitle: isBuyAtPriceStatus
                      //     ? "Are you sure you want to place a pending order?"
                      //     : "Are you sure you want to buy ${userInputController.text} grams of gold?",
                      // noButtonTitle: "Cancel",
                      // yesButtonTitle: isBuyAtPriceStatus
                      //     ? "Confirm"
                      //     : "Buy Gold",
                      isLoadingState: tradeStateWatchProvider.isButtonState,
                      onNoPress: () async {
                        _focusNode.unfocus();
                        _focusBuyAtPrice.unfocus();
                        Navigator.pop(context);
                      },
                      onYesPress: () async {
                        Navigator.pop(context);
                        _focusNode.unfocus();
                        _focusBuyAtPrice.unfocus();

                        if (!context.mounted) return;
                        await ref
                            .read(tradeProvider.notifier)
                            .userCanBuyGold(
                              context: context,
                              tradeMoney: num.tryParse(calculatedValue) ?? 0.0,
                              tradeMetal:
                                  num.tryParse(
                                    userInputController.text.trim(),
                                  ) ??
                                  0.0,
                              buyAtPriceStatus: isBuyAtPriceStatus,
                              buyAtPrice: isBuyAtPriceStatus
                                  ? num.tryParse(
                                      buyAtPriceController.text.trim(),
                                    )
                                  : null,

                              // num.tryParse(
                              //         buyAtPriceController.text.trim()) ??
                              //     0.0,
                              buyingPrice: buyingPriceInOneGram,
                            )
                            .then((onValue) {
                              if (!context.mounted) return;
                              userInputController.clear();
                              buyAtPriceController.clear();
                              setState(() {
                                calculatedValue = '0.00';
                                isBuyAtPriceStatus = false;
                              });
                            });
                      },
                    );
                  } else {
                    Toasts.getErrorToast(
                      gravity: ToastGravity.TOP,
                      text: checkUserBuyAtPrice
                          ? AppLocalizations.of(
                              context,
                            )!.please_enter_valid_price
                          // "Please enter a valid price."
                          : AppLocalizations.of(
                              context,
                            )!.invest_price_less_than_buying,
                      // "Enter a price that is less than or equal to the current buying price.",
                      duration: const Duration(seconds: 2),
                    );
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     content: GetGenericText(
                    //       text: checkUserBuyAtPrice
                    //           ? 'Enter a valid price.'
                    //           : "Enter price less than or equal to the buying price",
                    //       fontSize: 14,
                    //       fontWeight: FontWeight.w500,
                    //       color: AppColors.whiteColor,
                    //     ),
                    //     duration: const Duration(seconds: 2),
                    //   ),
                    // );
                  }
                } else {
                  if (userInputController.text.isNotEmpty) {
                    debugPrint("BuyGoldClicked");
                    _focusNode.unfocus();
                    _focusBuyAtPrice.unfocus();

                    // Ensure providers are in data state
                    final goldPriceState = ref.read(goldPriceProvider);
                    final mainState = ref.read(homeProvider);

                    if (goldPriceState is AsyncError ||
                        mainState is AsyncError) {
                      Toasts.getErrorToast(
                        gravity: ToastGravity.TOP,
                        text: AppLocalizations.of(
                          context,
                        )!.unable_to_fetch_data,
                        // "Unable to retrieve the latest data. Please try again.",
                        duration: const Duration(seconds: 2),
                      );

                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: GetGenericText(
                      //       text:
                      //           'Unable to fetch latest data. Please try again.',
                      //       fontSize: 14,
                      //       fontWeight: FontWeight.w500,
                      //       color: AppColors.whiteColor,
                      //     ),
                      //     duration: const Duration(seconds: 2),
                      //   ),
                      // );
                      return;
                    }

                    if (goldPriceState is AsyncLoading ||
                        mainState is AsyncLoading) {
                      Toasts.getErrorToast(
                        gravity: ToastGravity.TOP,
                        text: AppLocalizations.of(
                          context,
                        )!.data_loading,
                        // "Data is loading. Please wait.",
                        duration: const Duration(seconds: 2),
                      );
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: GetGenericText(
                      //       text: 'Data is loading. Please wait.',
                      //       fontSize: 14,
                      //       fontWeight: FontWeight.w500,
                      //       color: AppColors.whiteColor,
                      //     ),
                      //     duration: const Duration(seconds: 2),
                      //   ),
                      // );
                      return;
                    }

                    // Get wallet balance
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

                    // Validate calculatedValue
                    if (calculatedValue.isEmpty ||
                        calculatedValue == _defaultValue) {
                      Toasts.getSuccessToast(
                        text: AppLocalizations.of(
                          context,
                        )!.invalid_amount,
                        // "Invalid amount. Please enter a valid number.",
                        duration: const Duration(seconds: 2),
                      );
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: GetGenericText(
                      //       text: 'Invalid amount. Please enter a valid value.',
                      //       fontSize: 14,
                      //       fontWeight: FontWeight.w500,
                      //       color: AppColors.whiteColor,
                      //     ),
                      //     duration: const Duration(seconds: 2),
                      //   ),
                      // );
                      return;
                    }

                    // Get input amount with validation
                    final inputAmount = double.tryParse(calculatedValue) ?? 0.0;

                    // Detailed logging
                    debugPrint(
                      "inputAmount: $inputAmount, walletBalance: $walletBalance, calculatedValue: $calculatedValue",
                    );

                    // Add tolerance for floating-point comparison
                    // const tolerance = 0.01;
                    // if (walletBalance < (inputAmount - tolerance)) {
                    //   // Generic popup widget for insufficient balance
                    //   await genericPopUpWidget(
                    //     context: context,
                    //     heading: "Insufficient Balance",
                    //     subtitle:
                    //         "Your balance ($walletBalance AED) is less than the required amount ($inputAmount AED). Please add funds.",
                    //     noButtonTitle: "Close",
                    //     yesButtonTitle: "Add Funds",
                    //     isLoadingState: false,
                    //     onNoPress: () async {
                    //       _focusNode.unfocus();
                    //       _focusBuyAtPrice.unfocus();
                    //       Navigator.pop(context);
                    //     },
                    //     onYesPress: () async {
                    //       _focusNode.unfocus();
                    //       _focusBuyAtPrice.unfocus();
                    //       Navigator.pop(context);
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => const AddFundScreen(),
                    //         ),
                    //       );
                    //     },
                    //   );
                    //   return;
                    // }

                    /// Proceed with confirmation popup
                    await genericPopUpLivePriceWidget(
                      autoCloseAfterSeconds: 5,
                      context: context,
                      heading: AppLocalizations.of(context)!.confirmation,
                      subtitle: isBuyAtPriceStatus
                          ? AppLocalizations.of(context)!.place_order_confirm
                          : AppLocalizations.of(
                              context,
                            )!.invest_confirmation_message(
                              userInputController.text.trim(),
                            ),
                      noButtonTitle: AppLocalizations.of(context)!.cancel,
                      yesButtonTitle: isBuyAtPriceStatus
                          ? AppLocalizations.of(context)!.place_order
                          : AppLocalizations.of(context)!.confirm_purchase,
                      isLoadingState: tradeStateWatchProvider.isButtonState,
                      onNoPress: () async {
                        _focusNode.unfocus();
                        _focusBuyAtPrice.unfocus();
                        Navigator.pop(context);
                      },
                      onYesPress: () async {
                        Navigator.pop(context);
                        _focusNode.unfocus();
                        _focusBuyAtPrice.unfocus();
                        if (!context.mounted) return;
                        await ref
                            .read(tradeProvider.notifier)
                            .userCanBuyGold(
                              context: context,
                              tradeMoney: num.tryParse(calculatedValue) ?? 0.0,
                              tradeMetal:
                                  num.tryParse(
                                    userInputController.text.trim(),
                                  ) ??
                                  0.0,
                              buyAtPriceStatus: isBuyAtPriceStatus,
                              buyAtPrice: isBuyAtPriceStatus
                                  ? num.tryParse(
                                      buyAtPriceController.text.trim(),
                                    )
                                  : null,
                              buyingPrice: buyingPriceInOneGram,
                            );
                        userInputController.clear();
                        buyAtPriceController.clear();
                      },

                      ///  Live price section inside popup
                      livePriceWidget: Consumer(
                        builder: (context, ref, _) {
                          final goldPriceState = ref.watch(goldPriceProvider);
                          final inputValue =
                              double.tryParse(
                                userInputController.text.trim(),
                              ) ??
                              0.0;

                          return goldPriceState.when(
                            data: (data) {
                              double oneGramPrice =
                                  data.oneGramBuyingPriceInAED;
                              if (isBuyAtPriceStatus &&
                                  buyAtPriceController.text.isNotEmpty) {
                                final customPrice = double.tryParse(
                                  buyAtPriceController.text,
                                );
                                if (customPrice != null && customPrice > 0) {
                                  oneGramPrice = customPrice;
                                }
                              }
                              final total = inputValue * oneGramPrice;
                              buyingPriceInOneGram = oneGramPrice;
                              calculatedValue = total.toString();
                              return GetGenericText(
                                text:
                                    '${AppLocalizations.of(context)!.buy_gold_pop} ${oneGramPrice.toStringAsFixed(2)} ${AppLocalizations.of(context)!.aed_currency}',
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 18,
                                  tabletVal: 20,
                                ),
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGold500,
                                textAlign: TextAlign.center,
                              ).getChildCenter();
                            },
                            loading: () => const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white70,
                            ),
                            error: (_, __) => const Text(
                              'Error fetching price',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          );
                        },
                      ),
                    );
                    // Future.delayed(const Duration(seconds: 5), () {
                    //   if (Navigator.canPop(context)) {
                    //     Navigator.pop(context);
                    //   }
                    // });
                    // await genericPopUpWidget(
                    //   context: context,
                    //   heading: AppLocalizations.of(
                    //     context,
                    //   )!
                    //       .confirmation,
                    //   // "Confirmation",
                    //   subtitle: isBuyAtPriceStatus
                    //       ? AppLocalizations.of(
                    //           context,
                    //         )!
                    //           .place_order_confirm
                    //       // "Do you want to place this pending order?"
                    //       : AppLocalizations.of(
                    //           context,
                    //         )!
                    //           .invest_confirmation_message(
                    //           userInputController.text.trim(),
                    //         ), //"Do you want to buy ${userInputController.text.trim()} grams of gold now?",
                    //   noButtonTitle: AppLocalizations.of(
                    //     context,
                    //   )!
                    //       .cancel, //"Cancel",
                    //   yesButtonTitle: isBuyAtPriceStatus
                    //       ? AppLocalizations.of(
                    //           context,
                    //         )!
                    //           .place_order
                    //       // "Place Order"
                    //       : AppLocalizations.of(
                    //           context,
                    //         )!
                    //           .confirm_purchase,
                    //   //  "Confirm Purchase",
                    //   isLoadingState: tradeStateWatchProvider.isButtonState,
                    //   onNoPress: () async {
                    //     _focusNode.unfocus();
                    //     _focusBuyAtPrice.unfocus();
                    //     Navigator.pop(context);
                    //   },
                    //   onYesPress: () async {
                    //     Navigator.pop(context);
                    //     _focusNode.unfocus();
                    //     _focusBuyAtPrice.unfocus();

                    //     if (!context.mounted) return;
                    //     await ref
                    //         .read(tradeProvider.notifier)
                    //         .userCanBuyGold(
                    //           context: context,
                    //           tradeMoney: num.tryParse(calculatedValue) ?? 0.0,
                    //           tradeMetal: num.tryParse(
                    //                 userInputController.text.trim(),
                    //               ) ??
                    //               0.0,
                    //           buyAtPriceStatus: isBuyAtPriceStatus,
                    //           buyAtPrice: isBuyAtPriceStatus
                    //               ? num.tryParse(
                    //                   buyAtPriceController.text.trim(),
                    //                 )
                    //               : null,
                    //           buyingPrice: buyingPriceInOneGram,
                    //         )
                    //         .then((onValue) {
                    //       if (!context.mounted) return;
                    //       userInputController.clear();
                    //       buyAtPriceController.clear();
                    //       setState(() {
                    //         calculatedValue = '0.00';
                    //         isBuyAtPriceStatus = false;
                    //       });
                    //     });
                    //   },
                    // );
                  } else {
                    Toasts.getErrorToast(
                      gravity: ToastGravity.TOP,
                      text: AppLocalizations.of(
                        context,
                      )!.enter_valid_amount,
                      // "Enter a valid amount to proceed.",
                      duration: Duration(seconds: 2),
                    );

                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     content: GetGenericText(
                    //       text: 'Please enter a valid amount.',
                    //       fontSize: 14,
                    //       fontWeight: FontWeight.w500,
                    //       color: AppColors.whiteColor,
                    //     ),
                    //     duration: const Duration(seconds: 2),
                    //   ),
                    // );
                  }
                }
              },
            ),
            ConstPadding.sizeBoxWithHeight(height: 16),
          ],
        ),
      ),
    );
  }

  /// build amount price input section
  Widget _buildAmountPriceInputSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            Container(
              width: sizes!.isPhone ? sizes!.widthRatio * 360 : sizes!.width,
              height: sizes!.responsiveLandscapeHeight(
                phoneVal: 50,
                tabletVal: 70,
                tabletLandscapeVal: 80,
                isLandscape: sizes!.isLandscape(),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: sizes!.widthRatio * 12,
                vertical: sizes!.heightRatio * 12,
              ),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFF333333),
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
              ),
              child: Row(
                children: [
                  GetGenericText(
                    text: isSwitchValue
                        ? AppLocalizations.of(context)!.amount
                        : AppLocalizations.of(
                            context,
                          )!.price, //"Amount" : "Price ",
                    fontSize: sizes!.isPhone ? 14 : 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: sizes!.isPhone
                        ? sizes!.widthRatio * 200
                        : sizes!.widthRatio * 300,
                    child: TextFormField(
                      focusNode: _focusNode,
                      // Assign FocusNode
                      controller: userInputController,
                      cursorColor: Colors.white,
                      cursorHeight: sizes!.heightRatio * 20,
                      keyboardType: TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        DecimalTextInputFormatter(decimalRange: 2),
                        //LengthLimitingTextInputFormatter(15),
                      ],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        fontFamily: GoogleFonts.inter().fontFamily,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                        ),
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: AppColors.grey4Color,
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          fontFamily: GoogleFonts.inter().fontFamily,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  GetGenericText(
                    text: isSwitchValue
                        ? AppLocalizations.of(context)!.gram
                        : AppLocalizations.of(
                            context,
                          )!.aed_currency, //"Gram" : " AED",
                    fontSize: sizes!.isPhone ? 14 : 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Container(
              width: sizes!.isPhone ? sizes!.widthRatio * 361 : sizes!.width,
              height: sizes!.responsiveLandscapeHeight(
                phoneVal: 50,
                tabletVal: 70,
                tabletLandscapeVal: 80,
                isLandscape: sizes!.isLandscape(),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: sizes!.widthRatio * 12,
                vertical: sizes!.heightRatio * 12,
              ),
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: Color(0xFF333333),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
              ),
              child: Row(
                children: [
                  GetGenericText(
                    text: isSwitchValue
                        ? AppLocalizations.of(context)!.price
                        : AppLocalizations.of(
                            context,
                          )!.amount, //"Price " : "Amount",
                    fontSize: sizes!.isPhone ? 14 : 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey4Color,
                  ),

                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final goldPriceState = ref.watch(goldPriceProvider);

                        return goldPriceState.when(
                          data: (data) {
                            final oneGramAEDPrice =
                                data.oneGramBuyingPriceInAED;
                            final inputValue =
                                double.tryParse(
                                  userInputController.text.trim(),
                                ) ??
                                0.0;

                            double priceToUse = oneGramAEDPrice;
                            if (isBuyAtPriceStatus &&
                                buyAtPriceController.text.isNotEmpty) {
                              final buyAtPrice = double.tryParse(
                                buyAtPriceController.text.trim(),
                              );
                              if (buyAtPrice != null && buyAtPrice > 0) {
                                priceToUse = buyAtPrice;
                              }
                            }

                            final dynamicValue = (inputValue * priceToUse)
                                .toStringAsFixed(2);

                            return Text(
                              dynamicValue,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.grey4Color,
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                                fontFamily: GoogleFonts.inter().fontFamily,
                              ),
                            );
                          },
                          error: (error, stackTrace) => Text(
                            calculatedValue,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.grey4Color,
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              fontFamily: GoogleFonts.inter().fontFamily,
                            ),
                          ),
                          loading: () => Text(
                            calculatedValue,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.grey4Color,
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              fontFamily: GoogleFonts.inter().fontFamily,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Expanded(
                  //   child: Text(
                  //     calculatedValue,
                  //     textAlign: TextAlign.center,
                  //     style: TextStyle(
                  //       color: AppColors.grey4Color,
                  //       fontSize: 22,
                  //       fontWeight: FontWeight.w400,
                  //       fontFamily: GoogleFonts.inter().fontFamily,
                  //     ),
                  //   ),
                  // ),
                  GetGenericText(
                    text: isSwitchValue
                        ? AppLocalizations.of(context)!.aed_currency
                        : AppLocalizations.of(context)!.gram, //" AED" : "Gram",
                    fontSize: sizes!.isPhone ? 14 : 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey4Color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
