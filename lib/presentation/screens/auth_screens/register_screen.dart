import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/login_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/auth_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/already_have_account.dart';
import 'package:saveingold_fzco/presentation/widgets/demo_animated_text.dart';
import 'package:saveingold_fzco/presentation/widgets/signup_phone_text_field.dart';
import 'package:saveingold_fzco/presentation/widgets/term_conditions.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

import '../../widgets/deposit_amount_dropdown.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final surnameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String _phoneNumber = ''; // Add this line
  String _currentIsoCode = 'AE'; // Add this line
  String dialCode = "+971";
  bool _isDemoAccount = true;
  String Status = 'Real Account';

  String? selectedAmount;
  double amountDouble = 0.0;

  final List<String> amountOptions = [
    "10000 AED",
    "50000 AED",
    "100000 AED",
    "150000 AED",
    "200000 AED",
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _phoneNumber = phoneNumberController.text;
  }

  @override
  void dispose() {
    // TODO: implement dispose

    firstNameController.dispose();
    surnameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

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
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
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
                    ConstPadding.sizeBoxWithHeight(height: 20),
                    Directionality.of(context) == TextDirection.rtl
                        ? GetGenericText(
                            text: AppLocalizations.of(context)!.createAccount_title, //"Start Your Gold Journey",
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 24,
                              tabletVal: 32,
                            ),
                            fontWeight: FontWeight.w400,
                            color: AppColors.grey6Color,
                          ).getAlignRight()
                        : GetGenericText(
                            text: AppLocalizations.of(context)!.createAccount_title,//"Start Your Gold Journey",
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 24,
                              tabletVal: 32,
                            ),
                            fontWeight: FontWeight.w400,
                            color: AppColors.grey6Color,
                          ).getAlign(),

                    ConstPadding.sizeBoxWithHeight(height: 6),
                    Directionality.of(context) == TextDirection.rtl
                        ? GetGenericText(
                            text: AppLocalizations.of(
                              context,
                            )!.createAccount_subtitle, //"Your gateway to secure and seamless gold trading.",
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 16,
                              tabletVal: 18,
                            ),
                            fontWeight: FontWeight.w400,
                            color: AppColors.neutral80,
                          ).getAlignRight()
                        : GetGenericText(
                            text: AppLocalizations.of(
                              context,
                            )!.createAccount_subtitle, //"Your gateway to secure and seamless gold trading.",
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 16,
                              tabletVal: 18,
                            ),
                            fontWeight: FontWeight.w400,
                            color: AppColors.neutral80,
                          ).getAlign(),
                    ConstPadding.sizeBoxWithHeight(height: 6),
                    GetGenericText(
                      text: AppLocalizations.of(context)!.createAccount_warning,
                      // "Warning: For quick verification, please ensure that your document's first name, surname, and date of birth match the details you provide. Otherwise, face verification may fail.",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 10,
                        tabletVal: 12,
                      ),
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral90,
                      lines: 4,
                    ).getAlign(),

                    ConstPadding.sizeBoxWithHeight(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svg/user_icon.svg',
                              height: sizes!.responsiveHeight(
                                phoneVal: 24,
                                tabletVal: 32,
                              ),
                              width: sizes!.responsiveWidth(
                                phoneVal: 24,
                                tabletVal: 32,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              // Show "Real Account" if not demo, else "Demo Account"
                              // _isDemoAccount ? "Demo Account" : "Real Account",
                              _isDemoAccount
                                  ? AppLocalizations.of(
                                      context,
                                    )!.demo_accountToggle
                                  : AppLocalizations.of(
                                      context,
                                    )!.real_accountToggle,
                              style: GoogleFonts.inter(
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 16,
                                  tabletVal: 18,
                                ),
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutral90,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _isDemoAccount,
                          activeColor: AppColors.primaryGold500,
                          onChanged: (bool value) {
                            setState(() {
                              _isDemoAccount = value;
                              // Update Status accordingly if you need to track it separately
                              Status = _isDemoAccount ? "Demo" : "Real";
                            });
                          },
                        ),
                      ],
                    ).getAlign(),
                    ConstPadding.sizeBoxWithHeight(height: 10),

                    _isDemoAccount
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Directionality.of(context) != TextDirection.rtl?
                              SizedBox(
                                      // width: 350,
                                      child: DemoModeAnimatedText(
                                        text: AppLocalizations.of(context)!.demo_mode, //"Note: You are in Demo mode",
                                        fontSize: 18,
                                        color: AppColors.goldLightColor,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ):
                               SizedBox(
                                      // width: 350,
                                child: DemoModeAnimatedText(
                                  text: AppLocalizations.of(context)!.demo_mode,//"Note: You are in Demo mode",
                                  fontSize: 18,
                                  color: AppColors.goldLightColor,
                                  fontWeight: FontWeight.normal,
                                ),
                                                             ),
                            ],
                          )
                        : SizedBox.shrink(),
                    ConstPadding.sizeBoxWithHeight(height: 10),

                    CommonTextFormField(
                      title: "title",
                      hintText: AppLocalizations.of(context)!.user_firstName,//"Amro",
                      labelText: AppLocalizations.of(
                        context,
                      )!.first_name, //"First Name (Legal Name)",
                      controller: firstNameController,
                      textInputType: TextInputType.text,

                      isCapitalizationEnabled: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!.please_enter_first_name;
                          // 'Please enter first name';
                        }
                        return null;
                      },
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 20),
                    CommonTextFormField(
                      title: "title",
                      hintText: AppLocalizations.of(context)!.user_lastName,//"Jaber",
                      labelText: AppLocalizations.of(
                        context,
                      )!.surname, //"Surname (Legal Name)",
                      controller: surnameController,
                      textInputType: TextInputType.text,

                      isCapitalizationEnabled: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!.please_enter_surname;
                          // 'Please enter surname';
                        }
                        return null;
                      },
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 20),
                    CommonTextFormField(
                      title: "title",
                      hintText: "jondoe@example.com",
                      labelText:AppLocalizations.of(context)!.email_address,
                          //"Email Address",
                      controller: emailController,
                      textInputType: TextInputType.emailAddress,

                      isCapitalizationEnabled: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!.please_enter_email;
                          // 'Please enter email';
                        } else if (!value.validateEmail()) {
                          return AppLocalizations.of(
                            context,
                          )!.invalid_email;
                          // 'Invalid email';
                        }
                        return null;
                      },
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 20),
                    CommonPhoneFieldWithDropdown(
                      title: AppLocalizations.of(
                        context,
                      )!.phone_number, //"Phone Number",
                      hintText: "52 00 00 000",
                      controller: phoneNumberController,
                      onPhoneNumberChanged: (updatedPhoneNumber, isoCode, dCode) {
                        _phoneNumber = updatedPhoneNumber;
                        _currentIsoCode = isoCode;
                        dialCode = dCode;
                      },
                      isoCode: "AE",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.enter_valid_phone;//"Enter a valid phone number";
                          // AppLocalizations.of(
                          //   context,
                          // )!.please_enter_email_or_phone;

                          // 'Please enter phone number';
                        }

                        return null;
                      },
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 20),
                    CommonTextFormField(
                      title: "title",
                      hintText: "********",
                      obscureText: true,
                      labelText: AppLocalizations.of(
                        context,
                      )!.password, //"Password",
                      controller: passwordController,
                      textInputType: TextInputType.text,

                      isCapitalizationEnabled: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!.please_enter_password;
                          // 'Please enter password';
                        } else if (!value.validatePassword()) {
                          return AppLocalizations.of(
                            context,
                          )!.password_complexity_requirement;
                          // 'Password must be at least 8 characters, including capital letter, digit, and special character';
                        }
                        return null;
                      },
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 20),
                    CommonTextFormField(
                      title: "title",
                      hintText: "********",
                      labelText: AppLocalizations.of(
                        context,
                      )!.confirm_password, //"Confirm Password",
                      obscureText: true,
                      controller: confirmPasswordController,
                      textInputType: TextInputType.text,

                      isCapitalizationEnabled: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!.please_enter_password;
                          // 'Please enter password';
                        } else if (!value.validatePassword()) {
                          return AppLocalizations.of(
                            context,
                          )!.password_complexity_requirement;
                          // 'Password must be at least 8 characters, including capital letter, digit, and special character';
                        } else if (value.trim() !=
                            passwordController.text.toString().trim()) {
                          return AppLocalizations.of(context)!.confirm_pwd;//'Password do not match, Please re-enter confirm paswword.';
                        }
                        return null;
                      },
                    ),

                    ConstPadding.sizeBoxWithHeight(height: 20),
                    _isDemoAccount
                        ? CommonDropdownFormField(
                            labelText: AppLocalizations.of(
                              context,
                            )!.select_amount, //"Select Amount",
                            hintText: AppLocalizations.of(
                              context,
                            )!.select_amount, //"Select Amount",
                            items: amountOptions,
                            value: selectedAmount,
                            hineClr: AppColors.whiteColor,
                            onChanged: (value) {
                              setState(() {
                                selectedAmount = value;
                                print(
                                  "Raw value from dropdown: $value (${value.runtimeType})",
                                );

                                // Clean string if needed
                                amountDouble =
                                    double.tryParse(
                                      value?.toString().replaceAll(
                                            RegExp(r'[^0-9.]'),
                                            '',
                                          ) ??
                                          "0",
                                    ) ??
                                    0.0;

                                print("deposit as double: $amountDouble");
                              });
                            },

                            validator: (value) => value == null
                                ? AppLocalizations.of(
                                    context,
                                  )!.please_select_amount
                                //  "Please select an amount"
                                : null,
                          )
                        : SizedBox.shrink(),
                    ConstPadding.sizeBoxWithHeight(height: 10),
                    GetGenericText(
                      text: AppLocalizations.of(context)!.password_hint,
                      // "Combine uppercase/lowercase letters, numbers and special characters.",
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral90,
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ),
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 10),

                    ButtonWidget(
                      title: AppLocalizations.of(
                        context,
                      )!.create_account,
                      //  "Create Account",
                      isLoadingState: authStateWatchProvider.isButtonState,
                      onTap: () async {
                        print("Current iso=$_currentIsoCode");
                        if (_formKey.currentState?.validate() ?? false) {
                          // sendOtpForSignUp
                          /// user register
                          final body = {
                            "userType": _isDemoAccount ? "Demo" : "Real",
                            "dialCode": dialCode,
                            "isoCode": _currentIsoCode,
                            "firstName": firstNameController.text.trim(),
                            "surname": surnameController.text.trim(),
                            "email": emailController.text.trim(),
                            "phoneNumber": _phoneNumber.replaceFirst('+', '00'),
                            "password": passwordController.text.trim(),
                            "deposit": amountDouble,
                          };
                          await authStateReadProvider.sendOtpForSignUp(
                            email: emailController.text.trim(),
                            phoneNumber: _phoneNumber.replaceFirst('+', '00'),
                            data: body,
                            navigate: true,
                            context: context,
                          );
                          // await authStateReadProvider.userRegister(
                          //   body: body,
                          //   // email: emailController.text.toString().trim(),
                          //   // firstName:
                          //   //     firstNameController.text.toString().trim(),
                          //   // isDemo: _isDemoAccount,

                          //   // surname: surnameController.text.toString().trim(),
                          //   // // dateOfBirthday: "2010-01-21",
                          //   // phoneNumber: _phoneNumber,
                          //   // // Use the updated _phoneNumber
                          //   // password: passwordController.text.toString().trim(),
                          //   // deposit: amountDouble,
                          //   context: context,
                          // );
                        }
                      },
                    ),

                    ConstPadding.sizeBoxWithHeight(height: 16),
                    AlreadyHaveAccountText(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ),

                      regularColor: AppColors.neutral90,
                    ),

                    /// already have account
                    ConstPadding.sizeBoxWithHeight(height: 20),

                    /// terms
                    TermsAndPrivacyText(),
                    ConstPadding.sizeBoxWithHeight(height: 20),
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
