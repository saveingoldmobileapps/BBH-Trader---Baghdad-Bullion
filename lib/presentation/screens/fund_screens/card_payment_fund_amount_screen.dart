import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:logger/logger.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/core/sound_services.dart';
import 'package:saveingold_fzco/core/sounds/app_sounds.dart';
import 'package:saveingold_fzco/data/data_sources/local_database/local_database.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/feature_injection.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/payment_option_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CardPaymentFundAmountScreen extends ConsumerStatefulWidget {
  const CardPaymentFundAmountScreen({super.key});

  @override
  ConsumerState createState() => _FundAmountScreenState();
}

class _FundAmountScreenState
    extends ConsumerState<CardPaymentFundAmountScreen> {
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
          text: AppLocalizations.of(
            context,
          )!.dep_amount_title, //"Deposit Amount",
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
                    labelText: AppLocalizations.of(context)!.amount, //"Amount",
                    controller: amountController,
                    textInputType: TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(
                          context,
                        )!.enter_amount_plz; //'Please enter amount';
                      }
                      final amount = num.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return AppLocalizations.of(
                          context,
                        )!.enter_correct_amount; //'Please add correct amount';
                      }
                      if (amount < 100) {
                        return 'Minimum deposit amount is AED 100';
                      }
                      return null;
                    },
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 4),
                  Directionality.of(context) == TextDirection.rtl
                      ? GetGenericText(
                          text: AppLocalizations.of(
                            context,
                          )!.dep_min_amount_note,
                          // "Minimum deposit amount is AED 100, charges may apply",
                          fontSize: sizes!.isPhone ? 11 : 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey3Color,
                        ).getAlignRight()
                      : GetGenericText(
                          text: AppLocalizations.of(
                            context,
                          )!.dep_min_amount_note,
                          // "Minimum deposit amount is AED 100, charges may apply",
                          fontSize: sizes!.isPhone ? 11 : 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey3Color,
                        ).getAlign(),
                  const Spacer(),
                  LoaderArrowButton(
                    title: AppLocalizations.of(context)!.continu, //"Continue",
                    isLoadingState: paymentOptionWatchProvider.isButtonState,
                    onTap: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        FocusScope.of(context).unfocus();
                        Toasts.getWarningToast(
                          text: AppLocalizations.of(context)!.wait_please,
                        );
                        // Toasts.getWarningToast(text: "Please wait...");

                        /// make card payment with stripe
                        await payUsingCardOption(
                          amount: amountController.text.toString().trim(),
                          paymentMethod: "Card",
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

  ///pay using card option
  Future<void> payUsingCardOption({
    required String amount,
    required String paymentMethod,
  }) async {
    try {
      /// Fetch stored login user
      final result = await LocalDatabase.instance.getLoginUserFromStorage();
      var user = result?.payload?.userInfo;
      getLocator<Logger>().i(
        "userStoredData:: ${user?.id} | ${user?.firstName} | ${user?.surname} | ${user?.email} | ${user?.phoneNumber}",
      );

      // Step 1: Create Customer
      final customer = await ref
          .read(paymentOptionProvider.notifier)
          .createStripeCustomer(
            firstName: user?.firstName!.en ?? "",
            lastName: user?.surname!.en ?? "",
            email: user?.email ?? "",
            countryCode: 'AE',
          );

      getLocator<Logger>().i("stripeCustomer: ${customer['id']}");

      /// 1. Create a PaymentIntent on the server (see step 4)
      getLocator<Logger>().i("paymentAmount: $amount");
      final paymentIntent = await ref
          .read(paymentOptionProvider.notifier)
          .createPaymentIntent(
            amount: amount,
            currency: 'AED',
            customerId: customer['id'],
          );

      /// 2. Initialize the Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'Save In Gold',
          billingDetails: BillingDetails(
            name: '${user?.firstName} ${user?.surname}',
            email: user?.email ?? "",
            phone: user?.phoneNumber ?? "",
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
      debugPrint(
        "amountAfterTax: ${CommonService.calculateAfterTax(
          amount: amount,
        )}",
      );

      if (!mounted) return;
      SoundPlayer().playSound(AppSounds.depositSounmd);
      await ref
          .read(paymentOptionProvider.notifier)
          .savePaymentTransaction(
            orderAmount: CommonService.calculateAfterTax(
              amount: amount,
            ),
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
}
