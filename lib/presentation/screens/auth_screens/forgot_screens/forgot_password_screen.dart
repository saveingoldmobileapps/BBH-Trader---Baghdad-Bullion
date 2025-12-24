import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/core/validators.dart';
import 'package:saveingold_fzco/presentation/widgets/loader_button.dart';
import 'package:saveingold_fzco/presentation/widgets/text_form_field.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../sharedProviders/providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    final authStateWatchProvider = ref.watch(authProvider);
    final authStateReadProvider = ref.read(authProvider.notifier);

    sizes!.refreshSize(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        foregroundColor: AppColors.whiteColor,
      ),
      body: GestureDetector(
        onTap: () {
          // Remove focus to close the keyboard
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: sizes!.height,
          width: sizes!.width,
          decoration: const BoxDecoration(
            color: AppColors.greyScale1000,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    ConstPadding.sizeBoxWithHeight(height: 160),
                    Directionality.of(context) == TextDirection.rtl?
                    GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.forgotPassword_title, //"Forgot Password?",
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral92,
                    ).getAlignRight():
                    GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.forgotPassword_title, //"Forgot Password?",
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral92,
                    ).getAlign(),
                    ConstPadding.sizeBoxWithHeight(height: 4),
                    Directionality.of(context) == TextDirection.rtl?
                    GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.forgot_password_instruction,
                      //"Enter your email or phone number below to receive the instructions to change your password.",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral80,
                    ).getAlignRight():
                    GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.forgot_password_instruction,
                      //"Enter your email or phone number below to receive the instructions to change your password.",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral80,
                    ).getAlign(),
                    ConstPadding.sizeBoxWithHeight(height: 24),
                    CommonTextFormField(
                      // title: "Email or Phone Number",
                      // hintText: "Email or Phone Number",
                      // labelText: "Email or Phone Number",
                      title: AppLocalizations.of(context)!.email_or_phone,
                      hintText: AppLocalizations.of(context)!.email_or_phone,
                      labelText: AppLocalizations.of(context)!.email_or_phone,
                      controller: emailController,
                      textInputType: TextInputType.emailAddress,

                      isCapitalizationEnabled: false,
                      validator: ValidatorUtils.validateEmailOrPhone,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 32),
                    LoaderButton(
                      title: AppLocalizations.of(
                        context,
                      )!.change_passwordbtn, //"Change Password",
                      isLoadingState: authStateWatchProvider.isButtonState,
                      onTap: () async {
                        final input = emailController.text.trim();

                        if (_formKey.currentState?.validate() ?? false) {
                          if (RegExp(r'^[0-9+]+$').hasMatch(input)) {
                            String normalized = _normalizePhoneNumber(input);
                            debugPrint(
                              'User entered a phone number: $normalized',
                            );

                            await authStateReadProvider
                                .resendPhonePasscodeForgotPassword(
                                  phoneNumber: normalized,
                                  context: context,
                                );
                          } else {
                            debugPrint('User entered an email: $input');
                            await authStateReadProvider
                                .resendPasscodeForgotPassword(
                                  email: input,
                                  context: context,
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
        ),
      ),
    );
  }

  /// Normalizes local numbers for UAE, Iraq, Jordan into international format
  // String _normalizePhoneNumber(String input) {
  //   String phone = input.replaceAll(RegExp(r'[^0-9+]'), '');
  //   if (phone.startsWith('+')) {
  //     phone = phone.replaceFirst('+', '00');
  //   }

  //   // -------- Already International --------
  //   if (phone.startsWith('00971') || // UAE
  //       phone.startsWith('00964') || // Iraq
  //       phone.startsWith('00962') || // Jordan
  //       phone.startsWith('00966')) {
  //     // Saudi
  //     return phone;
  //   }

  //   // -------- Country code without leading 00 --------
  //   if (phone.startsWith('971') || // UAE
  //       phone.startsWith('964') || // Iraq
  //       phone.startsWith('962') || // Jordan
  //       phone.startsWith('966')) {
  //     // Saudi
  //     return '00$phone';
  //   }

  //   // -------- Local formats --------

  //   // UAE (05XXXXXXXX → 00971XXXXXXXX)
  //   if (phone.length == 10 && phone.startsWith('05')) {
  //     return '00971${phone.substring(1)}';
  //   }

  //   // Saudi (05XXXXXXXX → 00966XXXXXXXX)
  //   if (phone.length == 10 && phone.startsWith('05')) {
  //     return '00966${phone.substring(1)}'; 
  //   }

  //   // Jordan & Iraq (07XXXXXXXXX → detect by pattern)
  //   if (phone.length == 10 && phone.startsWith('07')) {
  //     String jordan = '00962${phone.substring(1)}';
  //     String iraq = '00964${phone.substring(1)}';
  //     if (RegExp(r'^009627[789]\d{6}$').hasMatch(jordan)) {
  //       return jordan;
  //     }
  //     return iraq;
  //   }

  //   return phone; // fallback
  }
  String _normalizePhoneNumber(String input) {
  // Remove everything except digits and '+'
  String phone = input.replaceAll(RegExp(r'[^0-9+]'), '');

  // 🔹 Replace + with 00
  if (phone.startsWith('+')) {
    phone = phone.replaceFirst('+', '00');
  }

  // 🔹 Already in international format (starts with 00)
  if (phone.startsWith('00')) {
    return phone;
  }

  //  Try to convert them to an international-like format
  // (You can enhance this with your default country if needed)
  if (phone.startsWith('0')) {
    // Remove the leading 0 and assume user’s country code is missing.
    return phone; 
  }

  return phone;


}
