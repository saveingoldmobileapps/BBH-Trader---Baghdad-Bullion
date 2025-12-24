import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

import '../../../sharedProviders/providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordScreen({
    required this.email,
    super.key,
  });

  @override
  ConsumerState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
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

    final authStateWatchProvider = ref.watch(authProvider);
    final authStateReadProvider = ref.read(authProvider.notifier);

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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GetGenericText(
                    text: AppLocalizations.of(context)!.change_passwordbtn,//"Change Password",
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ).getAlign(),
                  ConstPadding.sizeBoxWithHeight(height: 16),
                  CommonTextFormField(
                    title: "title",
                    hintText: "*******",
                    obscureText: true,
                    labelText: AppLocalizations.of(context)!.new_password,//"New Password",
                    controller: newPasswordController,
                    isCapitalizationEnabled: false,
                    textInputType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.val_enter_new_password;//"Please enter new password";
                      } else if (!value.validatePassword()) {
                        return AppLocalizations.of(context)!.val_password_rules;//'Password must be at least 8 characters, and must include a capital letter, a number, and a special character.';
                      }
                      return null;
                    },
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 16),
                  CommonTextFormField(
                    title: "title",
                    hintText: "*******",
                    obscureText: true,
                    labelText: AppLocalizations.of(context)!.confirm_password,//"Confirm Password",
                    controller: confirmPasswordController,
                    textInputType: TextInputType.text,
                    isCapitalizationEnabled: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.val_enter_confirm_password;//"Please enter confirm password";
                      } else if (value != newPasswordController.text) {
                        return AppLocalizations.of(context)!.val_passwords_do_not_match;//"Passwords do not match. Please re-enter confirm password.";
                      } 
                      return null;
                    },
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 24),
                  LoaderButton(
                    title: AppLocalizations.of(context)!.update_password_title,//"Update Password",
                    isLoadingState: authStateWatchProvider.isButtonState,
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState?.validate() ?? false) {
                        /// add new password with email
                        await authStateReadProvider.addNewPasswordWithEmail(
                          context: context,
                          email: widget.email,
                          password: newPasswordController.text
                              .toString()
                              .trim(),
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

