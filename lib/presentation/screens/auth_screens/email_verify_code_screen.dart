import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otp_timer_button/otp_timer_button.dart';
import 'package:pinput/pinput.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/change_email_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/auth_provider.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/home_provider.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/language_provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../widgets/button_widget.dart';

class EmailVerifyCodeScreen extends ConsumerStatefulWidget {
  final String email;

  const EmailVerifyCodeScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends ConsumerState<EmailVerifyCodeScreen> {
  // late final SmsRetriever smsRetriever;
  late final TextEditingController pinController;
  late final FocusNode focusNode;
  late final GlobalKey<FormState> formKey;
  OtpTimerButtonController otpTimerButtonController =
      OtpTimerButtonController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState

    formKey = GlobalKey<FormState>();
    pinController = TextEditingController();
    focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(authProvider.notifier)
          .resendFromHomeEmailPasscode(email: widget.email, context: context);
    });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    pinController.dispose();
    focusNode.dispose();
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

    final languageNotifier = ref.read(languageProvider.notifier);
    bool isRtl = languageNotifier.isRtl();

    ///provider
    final authStateWatchProvider = ref.watch(authProvider);
    final authStateReadProvider = ref.read(authProvider.notifier);

    const focusedBorderColor = Color(0xFFBBA473);
    const fillColor = Color(0x33BBA473);
    const borderColor = Color(0xFF939090);

    final defaultPinTheme = PinTheme(
      width: sizes!.widthRatio * 56,
      height: sizes!.isLandscape()
          ? sizes!.heightRatio * 84
          : sizes!.heightRatio * 56,
      textStyle: TextStyle(
        fontSize: sizes!.fontRatio * 22,
        color: Colors.white, //Color.fromRGBO(30, 60, 87, 1),
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
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
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
                isRtl
                    ? GetGenericText(
                        text: AppLocalizations.of(
                          context,
                        )!.verification, //"Verification"
                        fontSize: sizes!.isPhone ? 24 : 32,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey6Color,
                      ).getAlignRight()
                    : GetGenericText(
                        text: AppLocalizations.of(
                          context,
                        )!.verification, //"Verification"
                        fontSize: sizes!.isPhone ? 24 : 32,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey6Color,
                      ).getAlign(),
                ConstPadding.sizeBoxWithHeight(height: 8),
                isRtl
                    ? GetGenericText(
                        text:
                            "${AppLocalizations.of(context)!.enter_verify_code} ${CommonService.maskEmailAddress(widget.email)}.", //"Verification"
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey6Color,
                      ).getAlignRight()
                    : GetGenericText(
                        text:
                            "${AppLocalizations.of(context)!.enter_verify_code} ${CommonService.maskEmailAddress(widget.email)}.",
                        // "Enter the verify code you received on your ${CommonService.maskEmailAddress(widget.email)}.",
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.neutral80,
                      ).getAlign(),
                ConstPadding.sizeBoxWithHeight(height: 100),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Directionality(
                      // Specify direction if desired
                      textDirection: TextDirection.ltr,
                      child: Form(
                        key: _formKey,
                        child: Pinput(
                          length: 6,
                          // smsRetriever: smsRetriever,
                          controller: pinController,
                          focusNode: focusNode,
                          defaultPinTheme: defaultPinTheme,
                          separatorBuilder: (index) => const SizedBox(width: 8),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.enter_pin; //'Please enter pin';
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
                          text: AppLocalizations.of(
                            context,
                          )!.didnt_receive_code, //"Didn't receive the code?",
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
                            otpTimerButtonController.startTimer();
                            await authStateReadProvider.resendEmailPasscode(
                              email: widget.email,
                              context: context,
                            );
                          },
                          backgroundColor: AppColors.redColor,
                          buttonType: ButtonType.outlined_button,
                          text: Text(
                            AppLocalizations.of(context)!.resend, //Resend
                            style: TextStyle(
                              color: AppColors.whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          duration: 60,
                        ),
                      ],
                    ),
                  ],
                ),
                ConstPadding.sizeBoxWithHeight(height: 40),

                /// verify button
                getVerifyButton(
                  title: AppLocalizations.of(context)!.verify, //"Verify"
                  isLoadingState: authStateWatchProvider.isButtonState,
                  onTap: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      /// user email verify passcode
                      await authStateReadProvider
                          .userEmailVerifyPasscodeFromHome(
                            email: widget.email,
                            passcode: pinController.text.toString().trim(),
                            context: context,
                          )
                          .then((onValue) {
                            /// fetch user profile
                            ref.read(homeProvider.notifier).getUserProfile();
                            if (!context.mounted) return;
                            ref
                                .read(homeProvider.notifier)
                                .getHomeFeed(
                                  context: context,
                                  showLoading: true,
                                );
                          });
                    }
                  },
                ),
                ConstPadding.sizeBoxWithHeight(height: 40),
                ButtonWidget(
                  title: AppLocalizations.of(context)!.want_to_change_email,
                  isLoadingState: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeEmailScreen(
                          currentEmail: widget.email,
                        ),
                      ),
                    );
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

/// get verify button
Widget getVerifyButton({
  required String title,
  required bool isLoadingState,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: sizes!.isPhone ? sizes!.widthRatio * 380 : sizes!.width,
      height: //sizes!.heightRatio * 56,
      sizes!.responsiveLandscapeHeight(
        phoneVal: 56,
        tabletVal: 56,
        tabletLandscapeVal: 84,
        isLandscape: sizes!.isLandscape(),
      ),
      decoration: BoxDecoration(
        color: Color(0x33BBA473),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 1.50,
          color: Color(0xFFBBA473),
        ),
      ),
      child: Center(
        child: isLoadingState
            ? Container(
                width: sizes!.widthRatio * 26,
                height: sizes!.widthRatio * 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : GetGenericText(
                text: title,
                fontSize: sizes!.responsiveFont(
                  phoneVal: 18,
                  tabletVal: 20,
                ), //16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
      ),
    ),
  );
}
