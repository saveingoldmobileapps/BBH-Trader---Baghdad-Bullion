import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/core/hyperpay/hyperpay_checkout_service.dart';
import 'package:baghdad_bullion_house/core/hyperpay/hyperpay_env_config.dart';
import 'package:baghdad_bullion_house/core/sound_services.dart';
import 'package:baghdad_bullion_house/core/sounds/app_sounds.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/presentation/feature_injection.dart';
import 'package:baghdad_bullion_house/presentation/sharedProviders/providers/payment_option_provider.dart';
import 'package:baghdad_bullion_house/presentation/widgets/widget_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyperpay_sdk/hyperpay_sdk.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class HyperPayAddFundScreen extends ConsumerStatefulWidget {
  const HyperPayAddFundScreen({super.key});

  @override
  ConsumerState<HyperPayAddFundScreen> createState() =>
      _HyperPayAddFundScreenState();
}

class _HyperPayAddFundScreenState extends ConsumerState<HyperPayAddFundScreen> {
  final amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  String _oppwaAmount(String raw) {
    final v = double.tryParse(raw.trim()) ?? 0;
    return v.toStringAsFixed(2);
  }


  Future<void> _payWithHyperPay() async {
    if (!HyperPayEnvConfig.isConfigured) {
      Toasts.getErrorToast(
        text:
            'HyperPay is not configured. Set HYPERPAY_ACCESS_TOKEN and HYPERPAY_ENTITY_ID in .env.',
      );
      return;
    }

    FocusScope.of(context).unfocus();
    ref.read(paymentOptionProvider.notifier).setButtonState(true);

    final amountRaw = amountController.text.trim();
    final oppwaAmount = _oppwaAmount(amountRaw);

    try {
      final checkoutId = await HyperPayCheckoutService.createCheckoutId(
        amount: oppwaAmount,
      );
      getLocator<Logger>().i('HyperPay checkoutId: $checkoutId');

      if (!mounted) {
        ref.read(paymentOptionProvider.notifier).setButtonState(false);
        return;
      }

      final result = await HyperpaySdk.checkoutReadyUI(
        checkoutId: checkoutId,
        brands: ['VISA', 'MASTER', 'MADA'],
        shopperResultUrl: HyperPayEnvConfig.shopperResultUrl,
      );

      getLocator<Logger>().i(
        'HyperPay SDK Result: isSuccess=${result.isSuccess}, isCanceled=${result.isCanceled}, errorCode=${result.errorCode}, error=${result.errorMessage}',
      );

      if (result.isSuccess) {
        try {
          final statusLine =
              await HyperPayCheckoutService.fetchPaymentStatusLine(
                checkoutId,
              );
          getLocator<Logger>().i('HyperPay payment status: $statusLine');
        } catch (e, st) {
          getLocator<Logger>().w('HyperPay status fetch: $e');
          await Sentry.captureException(e, stackTrace: st);
        }

        if (!mounted) return;
        SoundPlayer().playSound(AppSounds.depositSounmd);
        await ref
            .read(paymentOptionProvider.notifier)
            .savePaymentTransaction(
              orderAmount: CommonService.calculateAfterTax(amount: amountRaw),
              paymentMethod: 'HyperPay',
              context: context,
            );
      } else if (!result.isSuccess && !result.isCanceled) {
        ref.read(paymentOptionProvider.notifier).setButtonState(false);
        Toasts.getErrorToast(
          text: result.errorMessage?.isNotEmpty == true
              ? result.errorMessage!
              : 'Payment failed',
        );
      } else {
        // Canceled
        ref.read(paymentOptionProvider.notifier).setButtonState(false);
        Toasts.getWarningToast(text: 'Payment was not completed');
      }
    } catch (e, stackTrace) {
      ref.read(paymentOptionProvider.notifier).setButtonState(false);
      getLocator<Logger>().e('HyperPay error: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
      Toasts.getErrorToast(text: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    final paymentOptionWatchProvider = ref.watch(paymentOptionProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.dep_amount_title,
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
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
                    title: 'title',
                    hintText: '1000',
                    labelText: AppLocalizations.of(context)!.amount,
                    controller: amountController,
                    textInputType: const TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.enter_amount_plz;
                      }
                      final amount = num.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return AppLocalizations.of(
                          context,
                        )!.enter_correct_amount;
                      }
                      if (amount < 100) {
                        return 'Minimum deposit amount is IQD 100';
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
                          fontSize: sizes!.isPhone ? 11 : 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey3Color,
                        ).getAlignRight()
                      : GetGenericText(
                          text: AppLocalizations.of(
                            context,
                          )!.dep_min_amount_note,
                          fontSize: sizes!.isPhone ? 11 : 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey3Color,
                        ).getAlign(),
                  const Spacer(),
                  LoaderArrowButton(
                    title: AppLocalizations.of(context)!.continu,
                    isLoadingState: paymentOptionWatchProvider.isButtonState,
                    onTap: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        Toasts.getWarningToast(
                          text: AppLocalizations.of(context)!.wait_please,
                        );
                        await _payWithHyperPay();
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
}
