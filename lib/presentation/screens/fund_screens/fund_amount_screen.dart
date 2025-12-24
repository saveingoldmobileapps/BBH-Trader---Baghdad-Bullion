import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/presentation/feature_injection.dart';
import 'package:saveingold_fzco/presentation/screens/fund_screens/account_detail_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/payment_option_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class FundAmountScreen extends ConsumerStatefulWidget {
  const FundAmountScreen({super.key});

  @override
  ConsumerState createState() => _FundAmountScreenState();
}

class _FundAmountScreenState extends ConsumerState<FundAmountScreen> {
  final amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    amountController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    /// Refresh sizes on orientation change
    sizes!.refreshSize(context);

    final paymentOptionWatchProvider = ref.watch(paymentOptionProvider);
    //final paymentOptionReadProvider = ref.read(paymentOptionProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: GetGenericText(
          text: "Deposit Amount",
          fontSize: 20,
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  ConstPadding.sizeBoxWithHeight(height: 12),
                  AmountTextFormField(
                    title: "title",
                    hintText: "1000",
                    labelText: "Amoun",
                    controller: amountController,
                    textInputType: TextInputType.numberWithOptions(signed: true,
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      final amount = num.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please add correct amount';
                      }
                      return null;
                    },
                  ),
                  const Spacer(),
                  // PlatformPayButton(
                  //   onPressed: () {},
                  // ),
                  LoaderArrowButton(
                    title: "Continue",
                    isLoadingState: paymentOptionWatchProvider.isButtonState,
                    onTap: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        FocusScope.of(context).unfocus();

                        /// make card payment with stripe
                        // await makeCardPaymentWithStripe(
                        //   amount: amountController.text.toString().trim(),
                        // );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccountDetailScreen(
                              amount: amountController.text.trim(),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 20),
                ],
              ).get16HorizontalPadding(),
            ),
          ),
        ),
      ),
    );
  }

  /// make card payment with stripe
  Future<void> makeCardPaymentWithStripe({
    required String amount,
    required String paymentMethod,
  }) async {
    try {
      /// 1. Create a PaymentIntent on the server (see step 4)
      getLocator<Logger>().i("paymentAmount: $amount");
      final paymentIntent = await _createPaymentIntent(
        amount: amount,
        currency: 'AED',
      );

      /// 2. Initialize the Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'Save In Gold',
          // googlePay: PaymentSheetGooglePay(
          //   merchantCountryCode: 'AE', // United Arab Emirates country code
          //   testEnv: true, // Set to false in production),
          //   currencyCode: "AED",
          //   // amount: amount,
          // ),
          applePay: PaymentSheetApplePay(
            merchantCountryCode: "AE",
          ),
          billingDetails: BillingDetails(
            address: Address(
              country: 'AE',
              city: '',
              state: '',
              line1: '',
              line2: '',
              postalCode: '',
            ),
          ),
        ),
      );

      /// 3. Display the Payment Sheet
      await Stripe.instance.presentPaymentSheet().then((onValue) {
        getLocator<Logger>().i("onValue: $onValue");
      });

      /// 4. Make a request to the server to confirm the payment intent
      /// add cc-Avenue transaction
      if (!mounted) return;
      await ref
          .read(paymentOptionProvider.notifier)
          .savePaymentTransaction(
            orderAmount: amount,
            paymentMethod: paymentMethod,
            context: context,
          );
    } on StripeException catch (exception, stackTrace) {
      // Payment failed
      getLocator<Logger>().e("stripeFailureError: $exception");
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    } catch (exception, stackTrace) {
      // Payment failed
      getLocator<Logger>().e("cardPaymentError: $exception");
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    }
  }

  /// make card payment with stripe
  // Future<void> payWithApplePay({
  //   required String amount,
  // }) async {
  //   try {
  //     /// 1. Create a PaymentIntent on the server (see step 4)
  //     getLocator<Logger>().i("paymentAmount: $amount");
  //     final paymentIntent = await _createPaymentIntent(
  //       amount: amount,
  //       currency: 'AED',
  //     );
  //
  //     /// 2. Initialize the Payment Sheet
  //     await Stripe.instance.initPaymentSheet(
  //       paymentSheetParameters: SetupPaymentSheetParameters(
  //         paymentIntentClientSecret: paymentIntent['client_secret'],
  //         style: ThemeMode.dark,
  //         merchantDisplayName: 'Save In Gold',
  //         // googlePay: PaymentSheetGooglePay(
  //         //   merchantCountryCode: 'AE', // United Arab Emirates country code
  //         //   testEnv: true, // Set to false in production),
  //         //   currencyCode: "AED",
  //         //   // amount: amount,
  //         // ),
  //         applePay: PaymentSheetApplePay(
  //           merchantCountryCode: "AE",
  //         ),
  //         billingDetails: BillingDetails(
  //           address: Address(
  //             country: 'AE',
  //             city: '',
  //             state: '',
  //             line1: '',
  //             line2: '',
  //             postalCode: '',
  //           ),
  //         ),
  //       ),
  //     );
  //
  //     /// 3. Display the Payment Sheet
  //     await Stripe.instance.presentPaymentSheet().then((onValue) {
  //       getLocator<Logger>().i("onValue: $onValue");
  //     });
  //
  //     /// 4. Make a request to the server to confirm the payment intent
  //     /// add cc-Avenue transaction
  //     if (!mounted) return;
  //     await ref.read(cCAvenueProvider.notifier).savePaymentTransaction(
  //           orderAmount: amount,
  //           paymentMethod: pay,
  //           context: context,
  //         );
  //   } on StripeException catch (exception, stackTrace) {
  //     // Payment failed
  //     getLocator<Logger>().e("stripeFailureError: $exception");
  //     await Sentry.captureException(
  //       exception,
  //       stackTrace: stackTrace,
  //     );
  //   } catch (exception, stackTrace) {
  //     // Payment failed
  //     getLocator<Logger>().e("cardPaymentError: $exception");
  //     await Sentry.captureException(
  //       exception,
  //       stackTrace: stackTrace,
  //     );
  //   }
  // }

  /// create payment intent
  Future<Map<String, dynamic>> _createPaymentIntent({
    required String amount,
    required String currency,
  }) async {
    try {
      // Set up the payment intent request
      Map<String, dynamic> body = {
        'amount': CommonService.calculateAmount(amount: amount),
        'currency': currency,
      };

      // Make the request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      return json.decode(response.body);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("createPaymentIntentError: $exception");
      throw Exception(exception.toString());
    }
  }
}
