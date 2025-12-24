import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

import '../../../l10n/app_localizations.dart';
import '../../sharedProviders/providers/auth_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
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

    /// states
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
        title: GetGenericText(
          text: AppLocalizations.of(context)!.update_password_title,//"Update Password",
          fontSize: sizes!.responsiveFont(
            phoneVal: 20,
            tabletVal: 24,
          ),
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
      ),
      body: Container(
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
                  ConstPadding.sizeBoxWithHeight(height: 16),
                  CommonTextFormField(
                    title: "title",
                    hintText: "******",
                    labelText: AppLocalizations.of(context)!.current_password,//"Enter Current Password",
                    controller: currentPasswordController,
                    textInputType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!
                            .val_enter_current_password;//"Please enter current password";
                      } else if (!value.validatePassword()) {
                        return AppLocalizations.of(context)!
                            .val_invalid_current_password;//"Invalid Current Password";//'Password must be at least 8 characters, and must include a capital letter, a number, and a special character.';
                      }
                      return null;
                    },
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 16),
                  CommonTextFormField(
                    title: "title",
                    hintText: "*******",
                    labelText: AppLocalizations.of(context)!.new_password,//"New Password",
                    controller: newPasswordController,
                    textInputType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!
                            .val_enter_new_password;//"Please enter new password";
                      } else if (!value.validatePassword()) {
                        return AppLocalizations.of(context)!
                            .password_complexity_requirement;//'Password must be at least 8 characters, and must include a capital letter, a number, and a special character.';
                      } else if (value == currentPasswordController.text) {
                        return AppLocalizations.of(context)!
                            .new_password_different;//'New password must be different from current password';
                      }
                      return null;
                    },
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 16),
                  CommonTextFormField(
                    title: "title",
                    hintText: "******",
                    labelText: AppLocalizations.of(context)!.confirm_password,//"Confirm Password",
                    controller: confirmPasswordController,
                    textInputType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!
                            .val_enter_confirm_password;//"Please enter confirm password";
                      } else if (value != newPasswordController.text) {
                        return AppLocalizations.of(context)!
                            .val_passwords_do_not_match;//"Passwords do not match. Please re-enter confirm password.";
                      } 
                      // else if (value == currentPasswordController.text) {
                      //   return 'New password must be different from current password';
                      // }
                      return null;
                    },
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 20),

                  /// update password
                  LoaderButton(
                    title: AppLocalizations.of(context)!.update_password_title,//"Update Password",
                    isLoadingState: authStateWatchProvider.isButtonState,
                    tabletLandscapeVal: 74,
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState?.validate() ?? false) {
                        /// update password
                        await authStateReadProvider.updatePassword(
                          context: context,
                          currentPassword: currentPasswordController.text,
                          newPassword: newPasswordController.text,
                        );
                      }
                    },
                  ),
                ],
              ).get16HorizontalPadding(),
            ),
          ),
        ),
      ),
    );
  }
}
