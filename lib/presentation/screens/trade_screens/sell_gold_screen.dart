import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/core/decimal_text_input_formatter.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/auth_kyc_screens/kyc_first_step_screen.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/auth_kyc_screens/kyc_second_step_screen.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/email_verify_code_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/home_provider.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/trade_provider/trade_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/live_price_container.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

import '../../sharedProviders/providers/sseGoldPriceProvider/sse_gold_price_provider.dart';
import '../main_home_screens/trade_screen.dart';

class SellGoldScreen extends ConsumerStatefulWidget {
  const SellGoldScreen({super.key});

  @override
  ConsumerState<SellGoldScreen> createState() => _SellGoldScreenState();
}

class _SellGoldScreenState extends ConsumerState<SellGoldScreen> {
  final TradeType tradeType = TradeType.sell;
  bool isSellAtProfitStatus = false;
  final sellAtProfitController = TextEditingController();
  final userInputController = TextEditingController();

  bool isSwitchValue = true;

  final _keyForm = GlobalKey<FormState>();
  final _focusNode = FocusNode(); // Add FocusNode
  final _focusSellAtPrice = FocusNode(); // Add FocusNode

  // Constants
  // static const double _usdToAed = 3.674; // 1 USD to AED
  // static const double _gramsPerOunce = 31.10347; // 1 ounce in grams
  static const String _defaultValue = '0.00';

  // State variables
  String calculatedValue = _defaultValue;
  double sellingPriceInOneGram = 0.00;

  Timer? _debounce; // For debouncing _updateCalculation

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mainState = ref.read(homeProvider);
      if (mainState.getHomeFeedResponse.payload == null) {
        ref
            .read(homeProvider.notifier)
            .getHomeFeed(
              context: context,
              showLoading: false,
            );
      }
    });

    userInputController.addListener(_debouncedUpdateCalculation);
    sellAtProfitController.addListener(
      _debouncedUpdateCalculation,
    ); // Add listener for sellAtProfit
  }

  /// debouncing
  void _debouncedUpdateCalculation() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _updateCalculation);
  }

  /// updating calculation
  void _updateCalculation() {
    final goldPriceState = ref.read(goldPriceProvider);
    goldPriceState.when(
      data: (data) {
        // final sellingPX =
        //     data.getGoldPriceResponse.prices?.last.mDSellingPx ?? 0.0;

        // final oneGramAEDPrice = (sellingPX * _usdToAed) / _gramsPerOunce;
        final oneGramAEDPrice = data.oneGramSellingPriceInAED;
        final inputValue =
            double.tryParse(userInputController.text.trim()) ?? 0.0;

        // Use sellAtProfit price if enabled and valid, otherwise use current price
        double priceToUse = oneGramAEDPrice;
        if (isSellAtProfitStatus && sellAtProfitController.text.isNotEmpty) {
          final sellAtProfit = double.tryParse(
            sellAtProfitController.text.trim(),
          );
          if (sellAtProfit != null && sellAtProfit > 0) {
            priceToUse = sellAtProfit;
          }
        }

        setState(() {
          calculatedValue = (inputValue * priceToUse).toStringAsFixed(2);
          sellingPriceInOneGram = oneGramAEDPrice;
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
    sellAtProfitController.removeListener(_debouncedUpdateCalculation);
    sellAtProfitController.dispose();
    userInputController.dispose();
    _focusNode.dispose(); // Dispose FocusNode
    _focusSellAtPrice.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);

    /// states
    final tradeStateWatchProvider = ref.watch(tradeProvider);
    //final goldPriceStateWatchProvider = ref.watch(goldPriceProvider);
    final mainStateWatchProvider = ref.watch(homeProvider);

    /// Get wallet balance with proper null safety
    // final walletBalance =
    //     double.tryParse(
    //       mainStateWatchProvider
    //               .getHomeFeedResponse
    //               .payload
    //               ?.walletExists
    //               ?.metalBalance
    //               ?.toString() ??
    //           '0',
    //     ) ??
    //     0.0;

    return Form(
      key: _keyForm,
      child: GestureDetector(
        onTap: () {
          _focusNode.unfocus();
          _focusSellAtPrice.unfocus();
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Selling Price Container
                LivePriceContainer(
                  title: "Selling Price",
                  isSelling: true,
                  todayHighLow: "",
                ),
                ConstPadding.sizeBoxWithWidth(width: 6),
                // Buying Price Container
                LivePriceContainer(
                  title: "Buying Price",
                  isSelling: false,
                  todayHighLow: "",
                ),
              ],
            ),
            ConstPadding.sizeBoxWithHeight(height: 16),
            _buildAmountPriceInputSection(),
            ConstPadding.sizeBoxWithHeight(height: 10),
            BuildSwitchOption(
              title: "Sell at Profit",
              value: isSellAtProfitStatus,
              onChanged: (value) {
                setState(() {
                  isSellAtProfitStatus = value;
                  _updateCalculation(); // Update calculation when switch is toggled
                });
              },
            ),
            if (isSellAtProfitStatus) ...[
              ConstPadding.sizeBoxWithHeight(height: 10),
              CommonTextFormField(
                focusNode: _focusSellAtPrice,
                title: "",
                hintText: "Per Gram AED",
                labelText: "Sell at Profit",
                controller: sellAtProfitController,
                inputFormatters: [
                  DecimalTextInputFormatter(decimalRange: 2),
                  //LengthLimitingTextInputFormatter(15),
                ],
                textInputType: TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                validator: isSellAtProfitStatus
                    ? (value) {
                        if (value!.isEmpty) {
                          return 'Enter a valid amount to proceed.';
                        }
                        return null;
                      }
                    : null,
              ),
            ],
            ConstPadding.sizeBoxWithHeight(height: 24),
            LoaderButton(
              title: "Sell Gold",
              isLoadingState: tradeStateWatchProvider.isButtonState,
              onTap: () async {
                ///If email not verified.
                if (!mainStateWatchProvider.isEmailVerified) {
                  await genericPopUpWidget(
                    isLoadingState: false,
                    context: context,
                    heading: "Email Verification Required",
                    subtitle:
                        "To continue, please verify your email address. Do you want to verify now?",
                    noButtonTitle: "Not Now",
                    yesButtonTitle: "Verify Now",
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
                if (mainStateWatchProvider.isEmailVerified &&
                    !mainStateWatchProvider.isBasicUserVerified) {
                  await genericPopUpWidget(
                    isLoadingState: false,
                    context: context,
                    heading: "Residency Verification Required",
                    subtitle:
                        "To continue, please complete your residency document verification. Would you like to proceed now?",
                    noButtonTitle: "Not Now",
                    yesButtonTitle: "Verify Now",
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
                if (mainStateWatchProvider.isEmailVerified &&
                    mainStateWatchProvider.isBasicUserVerified &&
                    !mainStateWatchProvider.isUserKYCVerified) {
                  await genericPopUpWidget(
                    isLoadingState: false,
                    context: context,
                    heading: "KYC Verification Required",
                    subtitle:
                        "To continue, please complete your KYC verification. Would you like to proceed now?",
                    noButtonTitle: "Later",
                    yesButtonTitle: "Proceed",
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
                if (isSellAtProfitStatus) {
                  final userInput = userInputController.text.trim();
                  final inputSellAtProfit = sellAtProfitController.text.trim();
                  final sellAtProfit =
                      double.tryParse(inputSellAtProfit) ?? 0.0;

                  final checkUserSellingAtProfit =
                      sellAtProfit > sellingPriceInOneGram;

                  //Validation for zero amount of gram
                  if (userInputController.text.trim().isEmpty) {
                    Toasts.getErrorToast(
                      gravity: ToastGravity.TOP,
                      text: 'Please add grams amount.',
                      duration: const Duration(seconds: 55),
                    );
                    return;
                  }

                  // Validation
                  if (userInput.isNotEmpty &&
                      inputSellAtProfit.isNotEmpty &&
                      checkUserSellingAtProfit) {
                    debugPrint("BuyGoldClicked");
                    _focusNode.unfocus();
                    _focusSellAtPrice.unfocus();

                    debugPrint(
                      "MetalBalance: ${mainStateWatchProvider.getHomeFeedResponse.payload?.walletExists?.metalBalance?.toString()}",
                    );

                    // Ensure providers are in data state
                    final goldPriceState = ref.read(goldPriceProvider);
                    final mainState = ref.read(homeProvider);

                    if (goldPriceState is AsyncError ||
                        mainState is AsyncError) {
                      Toasts.getErrorToast(
                        gravity: ToastGravity.TOP,
                        text: 'Unable to fetch latest data. Please try again.',
                        duration: const Duration(seconds: 2),
                      );
                      return;
                    }

                    if (goldPriceState is AsyncLoading ||
                        mainState is AsyncLoading) {
                      Toasts.getSuccessToast(
                        gravity: ToastGravity.TOP,
                        text: 'Data is loading. Please wait.',
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
                                  ?.metalBalance
                                  ?.toString() ??
                              '0',
                        ) ??
                        0.0;

                    // Validate calculatedValue
                    if (calculatedValue.isEmpty ||
                        calculatedValue == _defaultValue) {
                      Toasts.getErrorToast(
                        gravity: ToastGravity.TOP,
                        text: 'Invalid amount. Please enter a valid value.',
                        duration: const Duration(seconds: 2),
                      );
                      return;
                    }
                    // Detailed logging
                    debugPrint(
                      "walletBalance: $walletBalance, calculatedValue: $calculatedValue",
                    );

                    /// Get input amount with validation
                    var inputAmount =
                        double.tryParse(
                          userInputController.text.toString().trim(),
                        ) ??
                        0.0;

                    debugPrint("inputAmount: $inputAmount");

                    // Confirmation popup
                    await genericPopUpWidget(
                      context: context,
                      heading: "Confirmation",
                      subtitle: isSellAtProfitStatus
                          ? "Do you want to place this pending sell order?"
                          : "Do you want to sell ${userInputController.text.trim()} gram${userInputController.text == '1' ? '' : 's'} of gold now?",
                      noButtonTitle: "Cancel",
                      yesButtonTitle: isSellAtProfitStatus
                          ? "Place Order"
                          : "Confirm Sale",
                      isLoadingState: tradeStateWatchProvider.isButtonState,
                      onNoPress: () async {
                        Navigator.pop(context);
                        _focusNode.unfocus();
                        _focusSellAtPrice.unfocus();
                      },
                      onYesPress: () async {
                        Navigator.pop(context);
                        _focusNode.unfocus();
                        _focusSellAtPrice.unfocus();

                        if (!context.mounted) return;
                        await ref
                            .read(tradeProvider.notifier)
                            .userCanSellGold(
                              context: context,
                              tradeMoney: num.tryParse(calculatedValue) ?? 0.0,
                              tradeMetal:
                                  num.tryParse(
                                    userInputController.text.trim(),
                                  ) ??
                                  0.0,
                              sellAtProfitStatus: isSellAtProfitStatus,
                              sellAtProfit: isSellAtProfitStatus
                                  ? num.tryParse(
                                      sellAtProfitController.text.trim(),
                                    )
                                  : null,
                              sellingPrice: sellingPriceInOneGram,
                            )
                            .then((onValue) {
                              if (!context.mounted) return;
                              inputAmount = 0.0;
                              userInputController.clear();
                              sellAtProfitController.clear();
                              calculatedValue = '0.000';
                              isSellAtProfitStatus = false;
                            });
                      },
                    );
                  } else {
                    Toasts.getErrorToast(
                      gravity: ToastGravity.TOP,
                      text: checkUserSellingAtProfit
                          ? "Please enter a valid price."
                          : "Enter a price that is greater than or equal to the current selling price.",
                      duration: const Duration(seconds: 2),
                    );
                  }
                } else {
                  if (userInputController.text.isNotEmpty) {
                    debugPrint("BuyGoldClicked");
                    _focusNode.unfocus();
                    _focusSellAtPrice.unfocus();

                    // Ensure providers are in data state
                    final goldPriceState = ref.read(goldPriceProvider);
                    final mainState = ref.read(homeProvider);

                    if (goldPriceState is AsyncError ||
                        mainState is AsyncError) {
                      Toasts.getErrorToast(
                        gravity: ToastGravity.TOP,
                        text: "Unable to fetch latest data. Please try again.",
                        duration: const Duration(seconds: 2),
                      );
                      return;
                    }

                    if (goldPriceState is AsyncLoading ||
                        mainState is AsyncLoading) {
                      Toasts.getErrorToast(
                        gravity: ToastGravity.TOP,
                        text: "Data is loading. Please wait.",
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
                                  ?.metalBalance
                                  ?.toString() ??
                              '0',
                        ) ??
                        0.0;

                    // Validate calculatedValue
                    if (calculatedValue.isEmpty ||
                        calculatedValue == _defaultValue) {
                      Toasts.getSuccessToast(
                        text: "Invalid amount. Please enter a valid value.",
                        duration: const Duration(seconds: 2),
                      );
                      return;
                    }
                    // Detailed logging
                    debugPrint(
                      "walletBalance: $walletBalance, calculatedValue: $calculatedValue",
                    );

                    /// Get input amount with validation
                    var inputAmount =
                        double.tryParse(
                          userInputController.text.toString().trim(),
                        ) ??
                        0.0;

                    debugPrint("inputAmount: $inputAmount");

                    // Confirmation popup
                    await genericPopUpWidget(
                      context: context,
                      heading: "Confirmation",
                      subtitle: isSellAtProfitStatus
                          ? "Do you want to place this pending sell order?"
                          : "Do you want to sell ${userInputController.text} gram${userInputController.text == '1' ? '' : 's'} of gold now?",
                      noButtonTitle: "Cancel",
                      yesButtonTitle: isSellAtProfitStatus
                          ? "Place Order"
                          : "Confirm Sale",
                      isLoadingState: tradeStateWatchProvider.isButtonState,
                      onNoPress: () async {
                        Navigator.pop(context);
                        _focusNode.unfocus();
                        _focusSellAtPrice.unfocus();
                      },
                      onYesPress: () async {
                        Navigator.pop(context);
                        _focusNode.unfocus();
                        _focusSellAtPrice.unfocus();
                        if (!context.mounted) return;
                        await ref
                            .read(tradeProvider.notifier)
                            .userCanSellGold(
                              tradeMoney: num.tryParse(calculatedValue) ?? 0.0,
                              tradeMetal:
                                  num.tryParse(
                                    userInputController.text.trim(),
                                  ) ??
                                  0.0,
                              sellAtProfitStatus: isSellAtProfitStatus,
                              sellAtProfit: isSellAtProfitStatus
                                  ? num.tryParse(
                                      sellAtProfitController.text.trim(),
                                    )
                                  : null,
                              sellingPrice: sellingPriceInOneGram,
                              context: context,
                            )
                            .then((onValue) {
                              if (!context.mounted) return;
                              inputAmount = 0.0;
                              userInputController.clear();
                              sellAtProfitController.clear();
                              sellAtProfitController.clear();
                              calculatedValue = '0.00';
                              isSellAtProfitStatus = false;
                            });
                      },
                    );
                  } else {
                    Toasts.getErrorToast(
                      gravity: ToastGravity.TOP,
                      text: "Please enter a valid amount.",
                      duration: Duration(seconds: 2),
                    );
                  }
                }
              },
            ),
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
                    text: isSwitchValue ? "Amount" : "Price ",
                    fontSize: sizes!.isPhone ? 14 : 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: sizes!.widthRatio * 200,
                    child: TextFormField(
                      focusNode: _focusNode,
                      controller: userInputController,
                      keyboardType: TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done, 
                      inputFormatters: [
                        DecimalTextInputFormatter(decimalRange: 2),
                        LengthLimitingTextInputFormatter(15),
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
                    text: isSwitchValue ? "Gram" : " AED",
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
                    text: isSwitchValue ? "Price " : "Amount",
                    fontSize: sizes!.isPhone ? 14 : 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey4Color,
                  ),
                  // const Spacer(),
                  Expanded(
                    child: Text(
                      calculatedValue,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.grey4Color,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        fontFamily: GoogleFonts.inter().fontFamily,
                      ),
                    ),
                  ),
                  // const Spacer(),
                  GetGenericText(
                    text: isSwitchValue ? "AED" : "Gram",
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
