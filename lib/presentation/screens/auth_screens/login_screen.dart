import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:local_auth/local_auth.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/core/validators.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/forgot_screens/forgot_password_screen.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/register_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/auth_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/button_widget.dart';
import 'package:saveingold_fzco/presentation/widgets/create_account.dart';
import 'package:saveingold_fzco/presentation/widgets/text_form_field.dart';

import '../../../data/data_sources/local_database/local_database.dart'
    show LocalDatabase;
import '../../sharedProviders/providers/setting_provider/check_device_security.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();
  bool? isFaceEnabled;
  bool? isBiometricEnable;
  bool? deviceAuthEnable;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLocaleData();
    });

    super.initState();
  }

  Future<void> getLocaleData() async {
    bool faceIDEnabled = await LocalDatabase.instance.getFaceEnable() ?? false;
    // await LocalDatabase.instance.getFaceEnable() ?? false;
    bool deviceHasAuth = Platform.isAndroid
        ? await BiometricUtils.isFingerprintAvailable()
        : await BiometricUtils.isFaceLockAvailable();
    bool isFingerPrintEnabled =
        await LocalDatabase.instance.getFingerEnable() ?? false;
    // await LocalDatabase.instance.getFingerEnable() ?? false;
    if (mounted) {
      setState(() {
        isFaceEnabled = faceIDEnabled;
        isBiometricEnable = isFingerPrintEnabled;
        deviceAuthEnable = deviceHasAuth;
      });
    }

    // if (isBiometricEnable == true && deviceAuthEnable == true) {
    //   if (!mounted) return;
    //  await ref.read(authProvider.notifier).authenticateWithFingerprint(context: context,);
    // }
    await Future.delayed(Duration(seconds: 2));
    bool emailPasswordSaved =
        await LocalDatabase.instance.areCredentialsSaved();

    if (deviceHasAuth &&
        !faceIDEnabled &&
        !isFingerPrintEnabled &&
        emailPasswordSaved) {
      if (!mounted) return;
      Platform.isAndroid
          ? await ref.read(authProvider.notifier).authenticateWithFingerprint(
                context: context,
              )
          : await ref.read(authProvider.notifier).authenticateWithFaceUnlock(
                context: context,
              );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    passwordController.dispose();
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

    ///provider
    final authStateWatchProvider = ref.watch(authProvider);
    final authStateReadProvider = ref.read(authProvider.notifier);

    return Scaffold(
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
                    isBiometricEnable == true && deviceAuthEnable == true ||
                            (isFaceEnabled == true &&
                                Platform.isIOS &&
                                deviceAuthEnable == true)
                        ? ConstPadding.sizeBoxWithHeight(height: 65)
                        : ConstPadding.sizeBoxWithHeight(height: 75),
                    // Image.asset(
                    //   "assets/png/main_logo.png",
                    //   height: sizes!.responsiveHeight(
                    //     phoneVal: 90,
                    //     tabletVal: 150,
                    //   ),
                    //   //sizes!.heightRatio * 90,
                    //   width: sizes!.responsiveWidth(
                    //     phoneVal: 200,
                    //     tabletVal: 310,
                    //   ),
                    //   // sizes!.widthRatio * 200,
                    // ),
                    SvgPicture.asset(
                      "assets/svg/main_logo.svg",
                      height: sizes!.responsiveHeight(
                        phoneVal: 90,
                        tabletVal: 150,
                      ),
                      //sizes!.heightRatio * 90,
                      width: sizes!.responsiveWidth(
                        phoneVal: 200,
                        tabletVal: 310,
                      ),
                      // sizes!.widthRatio * 200,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 40),
                    // GetGenericText(
                    //   text: AppLocalizations.of(
                    //                   context,
                    //                 )!.welcome_back,
                    //   // text: "Welcome Back",
                    //   fontSize: 32,
                    //   fontWeight: FontWeight.w400,
                    //   color: AppColors.neutral92,
                    // ).getAlign(),
                    Directionality.of(context) == TextDirection.rtl
                        ? GetGenericText(
                            text: AppLocalizations.of(context)!.welcome_back,
                            fontSize: 32,
                            fontWeight: FontWeight.w400,
                            color: AppColors.neutral92,
                          ).getAlignRight()
                        : GetGenericText(
                            text: AppLocalizations.of(context)!.welcome_back,
                            fontSize: 32,
                            fontWeight: FontWeight.w400,
                            color: AppColors.neutral92,
                          ).getAlign(),

                    // GetGenericText(
                    //   text: sizes!.isPhone
                    //       ? "Your gateway to secure and seamless\ngold trading."
                    //       : "Your gateway to secure and seamless gold trading.",
                    //   fontSize: sizes!.responsiveFont(
                    //     phoneVal: 16,
                    //     tabletVal: 18,
                    //   ),
                    //   // 16,
                    //   fontWeight: FontWeight.w400,
                    //   color: AppColors.neutral80,
                    // ).getAlign(),
                    Directionality.of(context) == TextDirection.rtl
                        ? GetGenericText(
                            text: AppLocalizations.of(context)!.gateway_text,

                            // text: sizes!.isPhone
                            //     ? "Your gateway to secure and seamless\ngold trading."
                            //     : "Your gateway to secure and seamless gold trading.",
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 16,
                              tabletVal: 18,
                            ),
                            fontWeight: FontWeight.w400,
                            color: AppColors.neutral80,
                          ).getAlignRight()
                        : GetGenericText(
                            text: AppLocalizations.of(context)!.gateway_text,
                            // text: sizes!.isPhone
                            //     ? "Your gateway to secure and seamless\ngold trading."
                            //     : "Your gateway to secure and seamless gold trading.",
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 16,
                              tabletVal: 18,
                            ),
                            fontWeight: FontWeight.w400,
                            color: AppColors.neutral80,
                          ).getAlign(),

                    ConstPadding.sizeBoxWithHeight(height: 20),
                    CommonTextFormField(
                      title: AppLocalizations.of(context)!.email_or_phone,
                      hintText: AppLocalizations.of(context)!.email_or_phone,
                      labelText: AppLocalizations.of(context)!.email_or_phone,
                      // title: "Email or Phone Number",
                      // hintText: "Email or Phone Number",
                      // labelText: "Email or Phone Number",
                      controller: emailController,
                      textInputType: TextInputType.emailAddress,
                      validator: ValidatorUtils.validateEmailOrPhone,
                      isCapitalizationEnabled: false,
                    ),

                    ConstPadding.sizeBoxWithHeight(height: 20),
                    CommonTextFormField(
                      title: "title",
                      hintText: "**********",
                      obscureText: true,
                      // labelText: "Password",
                      labelText: AppLocalizations.of(context)!.password,
                      controller: passwordController,
                      isCapitalizationEnabled: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!
                              .please_enter_password;
                          // 'Please enter password';
                        } else if (!value.validatePassword()) {
                          return AppLocalizations.of(
                            context,
                          )!
                              .please_enter_password;
                          // 'Invalid email or password. Please try again.';
                        }
                        return null;
                      },
                    ),

                    ConstPadding.sizeBoxWithHeight(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: GetGenericText(
                        text: AppLocalizations.of(
                          context,
                        )!
                            .forgot_password, //"Forgot Password?",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ), // 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryGold500,
                      ).getAlignRight(),
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 36),

                    /// login button
                    // ButtonWidget(
                    //   title: AppLocalizations.of(context)!.loginBtn, //'Login',
                    //   isLoadingState: authStateWatchProvider.isButtonState,
                    //   onTap: () async {
                    //     FocusScope.of(context).unfocus();
                    //     if (_formKey.currentState?.validate() ?? false) {
                    //       String input = emailController.text.trim();
                    //       String formattedInput = input;

                    //       // Format phone numbers to international format
                    //       if (formattedInput.startsWith('+')) {
                    //         formattedInput = formattedInput.replaceFirst(
                    //           '+',
                    //           '00',
                    //         );
                    //       }
                    //       if (RegExp(r'^0?5\d{8}$').hasMatch(input)) {
                    //         // UAE
                    //         formattedInput =
                    //             '00971${input.replaceFirst(RegExp(r'^0'), '')}';
                    //       } else if (RegExp(
                    //         r'^07[789]\d{7}$',
                    //       ).hasMatch(input)) {
                    //         // Jordan
                    //         formattedInput = '00962${input.substring(1)}';
                    //       } else if (RegExp(
                    //         r'^07[0-9]\d{7}$',
                    //       ).hasMatch(input)) {
                    //         // Iraq
                    //         formattedInput = '00964${input.substring(1)}';
                    //       }
                    //       // -------- Saudi Arabia --------
                    //       else if (RegExp(r'^05\d{8}$').hasMatch(input)) {
                    //         formattedInput = '00966${input.substring(1)}';
                    //       }
                    //       await authStateReadProvider.userLogin(
                    //         email: formattedInput,
                    //         password: passwordController.text.trim(),
                    //         context: context,
                    //         showLoader: true,
                    //       );
                    //     }
                    //   },
                    // ),
                    ButtonWidget(
                      title: AppLocalizations.of(context)!.loginBtn, //'Login',
                      isLoadingState: authStateWatchProvider.isButtonState,
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        if (_formKey.currentState?.validate() ?? false) {
                          String input = emailController.text.trim();
                          String formattedInput = input;

                          // --- Normalize any country number to 00 format ---
                          if (formattedInput.startsWith('+')) {
                            formattedInput =
                                formattedInput.replaceFirst('+', '00');
                          }
                          // else if (formattedInput.startsWith('00')) {
                          //   // Optional: if you want to automatically assume local numbers should start with 00
                          //   // (You can remove this line if you want to allow raw local numbers)
                          //   formattedInput = '00$formattedInput';
                          // }

                          await authStateReadProvider.userLogin(
                            email: formattedInput,
                            password: passwordController.text.trim(),
                            context: context,
                            showLoader: true,
                            isFinger: false
                          );
                        }
                      },
                    ),

                    ConstPadding.sizeBoxWithHeight(height: 16),
                    //our
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Visibility(
                          visible: isBiometricEnable == true &&
                              deviceAuthEnable == true,
                          child: IconButton(
                            onPressed: () async {
                              /// Authenticate with fingerprint
                              await authStateReadProvider
                                  .authenticateWithFingerprint(
                                context: context,
                              );
                            },
                            icon: Icon(
                              Icons.fingerprint,
                              size: 60,
                              color: AppColors.primaryGold500,
                            ),
                          ),
                        ),
                        ConstPadding.sizeBoxWithWidth(width: 5),
                        Visibility(
                          visible: isFaceEnabled == true &&
                              Platform.isIOS &&
                              deviceAuthEnable == true,
                          child: IconButton(
                            onPressed: () async {
                              /// Authenticate with fingerprint
                              await authStateReadProvider
                                  .authenticateWithFaceUnlock(
                                context: context,
                              );
                            },
                            icon: SvgPicture.asset(
                              'assets/svg/faceId_icon.svg',
                              width: 55,
                              height: 55,
                              colorFilter: ColorFilter.mode(
                                AppColors.primaryGold500,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 16),
                    CreateAccountText(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      ),
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ),
                      regularColor: AppColors.neutral90,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 12),
                  ],
                ).get20HorizontalPadding(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
