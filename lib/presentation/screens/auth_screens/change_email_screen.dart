import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/auth_provider.dart';

import '../../../data/data_sources/local_database/local_database.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/pop_up_widget.dart';
import '../../widgets/text_form_field.dart';

class ChangeEmailScreen extends ConsumerStatefulWidget {
  final String currentEmail;

  const ChangeEmailScreen({
    super.key,
    required this.currentEmail,
  });

  @override
  ConsumerState<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends ConsumerState<ChangeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  final TextEditingController phoneNumberController = TextEditingController();
  @override
  void initState() {
    super.initState();
    getAndUpdatePhoneNumber();
    emailController = TextEditingController(text: widget.currentEmail);
  }

  Future<void> getAndUpdatePhoneNumber() async {
    String? phoneNumber = await LocalDatabase.instance.read(
      key: Strings.userPhoneNumber,
    );
    phoneNumberController.text = phoneNumber ?? "";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    final authWatch = ref.watch(authProvider);
    final authRead = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title:  Directionality.of(context) == TextDirection.rtl?
        GetGenericText(
          text: AppLocalizations.of(context)!.change_email,//"Change Email",
          fontSize: sizes!.isPhone ? 22 : 28,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ):
        GetGenericText(
          text: "Change Email",
          fontSize: sizes!.isPhone ? 22 : 28,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        color: AppColors.greyScale1000,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Directionality.of(context) == TextDirection.rtl?
                    GetGenericText(
                      text: AppLocalizations.of(context)!.pi_phone_number,//"Phone Number",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral80,
                    ):
                    GetGenericText(
                      text: AppLocalizations.of(context)!.pi_phone_number,//"Phone Number",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral80,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 16),

                    /// Email TextField
                    CommonTextFormField(
                      title: "title",
                      hintText: "09712345678",
                      readOnly: true,
                      labelText: AppLocalizations.of(context)!.phone_number,
                      controller: phoneNumberController,
                      textInputType: TextInputType.phone,
                      isCapitalizationEnabled: false,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 20),
                    Directionality.of(context) == TextDirection.rtl?
                    GetGenericText(
                      text: AppLocalizations.of(context)!.please_enter_email,//"Enter Email Address",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral80,
                    ):
                    GetGenericText(
                      text: AppLocalizations.of(context)!.please_enter_email,//"Enter Email Address",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral80,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 16),

                    /// Email TextField
                    CommonTextFormField(
                      title: "title",
                      hintText: "jondoe@example.com",
                      labelText: AppLocalizations.of(context)!.email_address,
                      controller: emailController,
                      textInputType: TextInputType.emailAddress,
                      isCapitalizationEnabled: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!.please_enter_email;
                        } else if (!value.validateEmail()) {
                          return AppLocalizations.of(
                            context,
                          )!.invalid_email;
                          // 'Invalid email';
                        }
                        return null;
                      },
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 40),

                    /// Update Button
                    GestureDetector(
                      onTap: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          final newEmail = emailController.text.trim();
                          final oldEmail = widget.currentEmail.trim();

                          // 1. Check if email is unchanged
                          if (newEmail == oldEmail) {
                            Toasts.getErrorToast(
                              text: AppLocalizations.of(context)!.plz_update_email,//"Please update Email",
                            );
                            return; //  stop execution here
                          }

                          // 2. If updated → show confirmation popup
                          await genericPopUpWidget(
                            isLoadingState: false,
                            context: context,
                            heading: Directionality.of(context) == TextDirection.rtl?AppLocalizations.of(context)!.warning:"Warning",
                            subtitle:
                                Directionality.of(context) == TextDirection.rtl?"${AppLocalizations.of(context)!.are_u_sure_to_update_email} ${emailController.text}":"${AppLocalizations.of(context)!.are_u_sure_to_update_email} ${emailController.text}",//"Are you sure you want to update email to $newEmail?",
                            noButtonTitle:Directionality.of(context) == TextDirection.rtl? AppLocalizations.of(context)!.no: "No",
                            yesButtonTitle: Directionality.of(context) == TextDirection.rtl?AppLocalizations.of(context)!.yes:"Yes",
                            onNoPress: () => Navigator.pop(context),
                            onYesPress: () async {
                              Navigator.pop(context);
                              await authRead.verifyAndUpdateEmail(
                                newEmail: newEmail,
                                context: context,
                              );
                            },
                          );
                        }
                      },
                      child: Container(
                        width: sizes!.width,
                        height: sizes!.responsiveLandscapeHeight(
                          phoneVal: 56,
                          tabletVal: 56,
                          tabletLandscapeVal: 84,
                          isLandscape: sizes!.isLandscape(),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x33BBA473),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 1.5,
                            color: const Color(0xFFBBA473),
                          ),
                        ),
                        child: Center(
                          child: authWatch.isButtonState
                              ? SizedBox(
                                  width: sizes!.widthRatio * 26,
                                  height: sizes!.widthRatio * 26,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : GetGenericText(
                                  text: Directionality.of(context) == TextDirection.rtl?AppLocalizations.of(context)!.update:"Update", // “Update”
                                  fontSize: sizes!.responsiveFont(
                                    phoneVal: 18,
                                    tabletVal: 20,
                                  ),
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
