import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:otp_timer_button/otp_timer_button.dart';
import 'package:pinput/pinput.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/auth_provider.dart';
import 'package:smart_auth/smart_auth.dart';

import '../../../l10n/app_localizations.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/pop_up_widget.dart';

class UpdateAccountVerifyCodeScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final Map<String, String> data;
  const UpdateAccountVerifyCodeScreen({
    required this.phoneNumber,
    required this.data,
    super.key,
  });

  @override
  ConsumerState createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState
    extends ConsumerState<UpdateAccountVerifyCodeScreen> {
  late final SmsRetriever smsRetriever;
  late final TextEditingController pinController;
  late final FocusNode focusNode;

  final _formKey = GlobalKey<FormState>();
  final smartAuth = SmartAuth.instance;

  OtpTimerButtonController otpTimerButtonController =
      OtpTimerButtonController();

  @override
  void initState() {
    // TODO: implement initState

    pinController = TextEditingController();
    focusNode = FocusNode();

    /// In case you need an SMS autofill feature
    smsRetriever = SmsRetrieverImpl(
      smartAuth,
      //SmartAuth(),
    );
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    pinController.dispose();
    focusNode.dispose();

    /// Removes the listeners if the SMS code is not received yet
    smartAuth.removeSmsRetrieverApiListener();

    /// Removes the listeners if the SMS code is not received yet
    smartAuth.removeUserConsentApiListener();
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
    final subtitle =
        "Once your profile is verified, you will be logged out automatically. Are you sure you want to continue?";
    final authStateWatchProvider = ref.watch(authProvider);
    final authStateReadProvider = ref.read(authProvider.notifier);

    const focusedBorderColor = Color(0xFFBBA473);
    const fillColor = Color(0x33BBA473);
    const borderColor = Color(0xFF939090);

    final defaultPinTheme = PinTheme(
      width: sizes!.widthRatio * 56,
      height: sizes!.heightRatio * 56,
      textStyle: TextStyle(
        fontSize: sizes!.fontRatio * 22,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        foregroundColor: AppColors.whiteColor,
      ),
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        decoration: const BoxDecoration(
          color: AppColors.greyScale1000,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ConstPadding.sizeBoxWithHeight(height: 40),
               Directionality.of(context) == TextDirection.rtl?
               GetGenericText(
                  text: AppLocalizations.of(context)!.verification,//"Verification",
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey6Color,
                ).getAlignRight():
                GetGenericText(
                  text: AppLocalizations.of(context)!.verification,//"Verification",
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey6Color,
                ).getAlign(),
                ConstPadding.sizeBoxWithHeight(height: 8),
                Directionality.of(context) == TextDirection.rtl?
                GetGenericText(
                  text:
                  "${AppLocalizations.of(context)!.enter_verify_code_phone}\n \u200E ${CommonService.maskPhoneNumber(phoneNumber: widget.phoneNumber)}.",
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.neutral80,
                ).getAlignRight():
                GetGenericText(
                  text:
                  "${AppLocalizations.of(context)!.enter_verify_code_phone}\n \u200E \n${CommonService.maskPhoneNumber(phoneNumber: widget.phoneNumber)}.",
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.neutral80,
                ).getAlign(),
                // Directionality.of(context) == TextDirection.rtl
                //     ? GetGenericText(
                //         text:
                //             "${AppLocalizations.of(context)!.enter_verify_code_phone} ${CommonService.maskPhoneNumber(phoneNumber: widget.phoneNumber)}.",
                //         //"Enter the verify code you received on your phone number: ${CommonService.maskPhoneNumber(phoneNumber: widget.phoneNumber)}.",
                //         fontSize: 16,
                //         fontWeight: FontWeight.w400,
                //         color: AppColors.neutral80,
                //       ).getAlignRight()
                //     : GetGenericText(
                //         text:
                //             "${AppLocalizations.of(context)!.enter_verify_code_phone} ${CommonService.maskPhoneNumber(phoneNumber: widget.phoneNumber)}.",
                //         //"Enter the verify code you received on your phone number: ${CommonService.maskPhoneNumber(phoneNumber: widget.phoneNumber)}.",
                //         fontSize: 16,
                //         fontWeight: FontWeight.w400,
                //         color: AppColors.neutral80,
                //       ).getAlign(),
                ConstPadding.sizeBoxWithHeight(height: 100),
                Directionality(
                  // Specify direction if desired
                  textDirection: TextDirection.ltr,
                  child: Form(
                    key: _formKey,
                    child: Pinput(
                      length: 6,
                      smsRetriever: smsRetriever,
                      controller: pinController,
                      focusNode: focusNode,
                      defaultPinTheme: defaultPinTheme,
                      separatorBuilder: (index) => const SizedBox(width: 8),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.enter_pin;//'Please enter pin';
                        } else {
                          return null;
                        }
                      },
                      hapticFeedbackType: HapticFeedbackType.lightImpact,
                      onCompleted: (pin) {
                        debugPrint('onCompleted: $pin');
                      },
                      onChanged: (value) {
                        debugPrint('onChanged: $value');
                      },
                      cursor: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 9),
                            width: sizes!.widthRatio * 22,
                            height: sizes!.heightRatio * 1,
                            color: focusedBorderColor,
                          ),
                        ],
                      ),
                      focusedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: focusedBorderColor),
                        ),
                      ),
                      submittedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          color: fillColor,
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(color: focusedBorderColor),
                        ),
                      ),
                      errorPinTheme: defaultPinTheme.copyBorderWith(
                        border: Border.all(color: Colors.redAccent),
                      ),
                    ),
                  ),
                ),
                ConstPadding.sizeBoxWithHeight(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GetGenericText(
                      text: AppLocalizations.of(context)!.didnt_receive_code,
                      //"Didn't receive the code? ",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.whiteColor,
                    ),
                    sizes!.isPhone
                        ? ConstPadding.sizeBoxWithWidth(width: 16)
                        : ConstPadding.sizeBoxWithWidth(width: 60),
                    OtpTimerButton(
                      controller: otpTimerButtonController,
                      onPressed: () async {
                        //clear otp on resend
                        pinController.clear();
                        otpTimerButtonController.loading();
                        if (!context.mounted) return;
                        await authStateReadProvider.sendOtpForChnagePhoneNumber(
                          navigate: false,
                          data: widget.data,
                          phoneNumber: widget.phoneNumber,
                          context: context,
                        );
                        otpTimerButtonController.startTimer();
                        // otpTimerButtonController.enableButton();
                      },
                      backgroundColor: AppColors.redColor,
                      buttonType: ButtonType.outlined_button,
                      text: Text(
                        AppLocalizations.of(context)!.resend,
                        //"Resend",
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      duration: 60,
                    ),
                  ],
                ).getAlign(),
                ConstPadding.sizeBoxWithHeight(height: 40),
                ButtonWidget(
                  title: AppLocalizations.of(context)!.update_Account,// "Update Account",
                  isLoadingState: authStateWatchProvider.isButtonState,
                  onTap: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      if (authStateWatchProvider.oneTimePassword ==
                          pinController.text.toString().trim()) {
                        genericPopUpWidget(
                          context: context,
                          heading: AppLocalizations.of(context)!.update_profile,//"Profile",
                          
                          subtitle: subtitle,
                          noButtonTitle: AppLocalizations.of(context)!.cancel,//"Cancel",
                          yesButtonTitle: AppLocalizations.of(context)!.update,//"Update",
                          isLoadingState: ref.watch(authProvider).isButtonState,
                          onNoPress: () {
                            Navigator.pop(context);
                          },
                          onYesPress: () async {
                            Navigator.pop(context); // close popup
                            await authStateReadProvider.editProfile(
                              updatedFields: widget.data,
                              context: context,
                            );
                          },
                        );
                      } else {
                        Toasts.getErrorToast(
                          gravity: ToastGravity.TOP,
                          text: AppLocalizations.of(context)!.invalid_otp,//"Invalid OTP:Please enter valid otp",
                        );
                      }
                    }
                  },
                ),
              ],
            ).get16HorizontalPadding(),
          ),
        ),
      ),
    );
  }
}

/// You, as a developer should implement this interface.
/// You can use any package to retrieve the SMS code. in this example we are using SmartAuth
class SmsRetrieverImpl implements SmsRetriever {
  const SmsRetrieverImpl(this.smartAuth);

  final SmartAuth smartAuth;

  @override
  Future<void> dispose() {
    return smartAuth.removeSmsRetrieverApiListener();
  }

  @override
  Future<String?> getSmsCode() async {
    final signature = await smartAuth.getAppSignature();
    debugPrint('App Signature: $signature');
    final res = await smartAuth.getSmsWithUserConsentApi();
    if (res.hasData) {
      debugPrint('userConsent: $res');
      final code = res.requireData.code;

      /// The code can be null if the SMS was received but
      /// the code was not extracted from it
      if (code == null) {
        return "not found";
      }

      return code;
    } else if (res.isCanceled) {
      debugPrint('userConsent canceled');
    } else {
      debugPrint('userConsent failed: $res');
    }
    return null;
  }

  @override
  bool get listenForMultipleSms => false;
}
