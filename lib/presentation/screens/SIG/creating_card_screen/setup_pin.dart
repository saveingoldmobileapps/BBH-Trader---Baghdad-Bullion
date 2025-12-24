import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_timer_button/otp_timer_button.dart';
import 'package:pinput/pinput.dart';
import 'package:saveingold_fzco/core/core_export.dart';

import '../../../../l10n/app_localizations.dart';

class SetPinScreen extends ConsumerStatefulWidget {
  const SetPinScreen({super.key});

  @override
  ConsumerState createState() => _SetPinScreenState();
}

class _SetPinScreenState extends ConsumerState<SetPinScreen> {
  late final TextEditingController pinController;
  late final FocusNode focusNode;
  late final GlobalKey<FormState> formKey;

  OtpTimerButtonController otpTimerButtonController =
      OtpTimerButtonController();
  @override
  void initState() {
    // TODO: implement initState

    formKey = GlobalKey<FormState>();
    pinController = TextEditingController();
    focusNode = FocusNode();

    /// In case you need an SMS autofill feature
    // smsRetriever = SmsRetrieverImpl(
    //   smartAuth,
    //   //SmartAuth(),
    // );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    return Scaffold(
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        color: AppColors.greyScale1000,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstPadding.sizeBoxWithHeight(height: 20),
                _buildHeader(),
                Expanded(
                  child: Center(
                    // Centers content vertically
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min, // Centers only the PIN fields
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildPinFields(title: "Enter Pin"),
                        ConstPadding.sizeBoxWithHeight(height: 25),
                        _buildPinFields(title: "Re-enter Pin"),
                      ],
                    ),
                  ),
                ),
                _buildContinueButton(),
                ConstPadding.sizeBoxWithHeight(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.arrow_back,
              color: AppColors.grey2Color,
            ),
            ConstPadding.sizeBoxWithWidth(width: 10),
            Text(
              "Set Your Pin",
              style: GoogleFonts.roboto(
                fontSize: sizes!.fontRatio * 22,
                fontWeight: FontWeight.bold,
                color: AppColors.grey2Color,
              ),
            ),
          ],
        ),
        ConstPadding.sizeBoxWithHeight(height: 10),
        Text(
          "Set your pin for ATM withdrawals.",
          style: GoogleFonts.roboto(
            fontSize: sizes!.fontRatio * 14,
            fontWeight: FontWeight.w400,
            color: AppColors.grey2Color,
          ),
        ),
      ],
    );
  }

  Widget _buildPinFields({required String title}) {
    const focusedBorderColor = Color(0xFFBBA473);
    //Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color(0x33BBA473); //Color.fromRGBO(243, 246, 249, 0);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.roboto(
            fontSize: sizes!.fontRatio * 16,
            fontWeight: FontWeight.w400,
            color: AppColors.grey2Color,
          ),
        ),
        ConstPadding.sizeBoxWithHeight(height: 10),
        Pinput(
          length: 6,
          controller: pinController,
          focusNode: focusNode,
          defaultPinTheme: defaultPinTheme,
          separatorBuilder: (index) => const SizedBox(width: 8),
          validator: (value) {
            // return value == '2222' ? null : 'Pin is incorrect';
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
      ],
    );
  }

  Widget _buildContinueButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: sizes!.width,
        height:
            sizes!.isPhone ? sizes!.heightRatio * 50 : sizes!.heightRatio * 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment(1.00, 0.01),
            end: Alignment(-1, -0.01),
            colors: [
              Color(0xFFBBA473),
              Color(0xFF675A3D),
            ],
          ),
        ),
        child: Center(
          child: GetGenericText(
            text: AppLocalizations.of(context)!.continu,//"Continue",
            fontSize: sizes!.isPhone ? 18 : 22,
            fontWeight: FontWeight.w500,
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }
}
