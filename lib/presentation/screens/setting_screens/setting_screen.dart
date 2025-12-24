import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/setting_screens/biometric_screen.dart';
import 'package:saveingold_fzco/presentation/screens/setting_screens/face_id_screen.dart';
import 'package:saveingold_fzco/presentation/screens/setting_screens/language_screen.dart';
import 'package:saveingold_fzco/presentation/screens/setting_screens/timezone_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/auth_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/switch_account.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

import '../../../data/data_sources/local_database/local_database.dart';
import 'change_password_screen.dart';
import 'edit_personal_info_screen.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  bool _isRealAccount = false;
  bool _loadingSwitch = true;
  String appVersion = '';

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = '${info.version}+${info.buildNumber}';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDemoStatus();

    _loadAppVersion();
  }

  Future<void> _loadDemoStatus() async {
    final isDemo = await LocalDatabase.instance.getIsDemo() ?? false;
    setState(() {
      _isRealAccount = !isDemo; // true if real, false if demo
      _loadingSwitch = false;
    });
  }

  Future<void> _onToggleChanged(bool newValue) async {
    if (newValue == true) {
      // User wants to switch to Real account
      final isDemo = await LocalDatabase.instance.getIsDemo() ?? false;
      if (isDemo) {
        if (!context.mounted) return;
        await genericPopUpWidget(
          isLoadingState: false,
          context: context,
          heading: AppLocalizations.of(
            context,
          )!
              .upgrade_real_account_title, //"Upgrade to Real Account",
          subtitle: AppLocalizations.of(context)!.upgrade_to_real_message,
              //"Please note, upgrading to a real account will result in the deletion of your existing demo account data.",
          noButtonTitle: AppLocalizations.of(
            context,
          )!
              .upgrade_real_account_later, //"Not Now",
          yesButtonTitle: AppLocalizations.of(
            context,
          )!
              .upgrade_real_account_now, //"Upgrade Now",
          onNoPress: () {
            Navigator.pop(context);

            setState(() {
              _isRealAccount = false;
            });
          },
          onYesPress: () async {
            Navigator.pop(context);
            // Call your upgrade API here or change user as per your logic
            await ref.read(authProvider.notifier).changeUser(context: context);

            // Update LocalDatabase to real user after upgrade
            await LocalDatabase.instance.setIsDemo(isDemo: false);

            setState(() {
              _isRealAccount = true;
            });
          },
        );
        // Don't toggle the switch until user confirms upgrade
        return;
      }
    }

    // If switching to Demo (OFF) or if user is already real, allow toggle directly
    await LocalDatabase.instance.setIsDemo(isDemo: !newValue);
    setState(() {
      _isRealAccount = newValue;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    final authStateReadProvider = ref.read(authProvider.notifier);

    final isDemo = LocalDatabase.instance.getIsDemo() ?? false;
    //final authStateWatchProvider = ref.watch(authProvider);
    sizes!.refreshSize(context);

    final environment = dotenv.env['ENVIRONMENT'] ?? 'staging';
    debugPrint("Environment: $environment");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.settings_title, //"User Settings",
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
            child: Column(
              children: [
                ConstPadding.sizeBoxWithHeight(height: 12),
                BuildSettingCard(
                  title: AppLocalizations.of(
                    context,
                  )!
                      .personalInfo_title, //"Personal Information",
                  subtitle: AppLocalizations.of(
                    context,
                  )!
                      .settings_personal_info_desc, //"Manage your personal details and preferences.",
                  iconString: "assets/svg/user_icon.svg",
                  onTap: () async {
                    final isDemo =
                        await LocalDatabase.instance.getIsDemo() ?? false;

                    // if (isDemo) {
                    //   if (!context.mounted) return;
                    //   await genericPopUpWidget(
                    //     isLoadingState: false,
                    //     context: context,
                    //     heading: AppLocalizations.of(context)!.upgrade_real_account_title,
                    //         //"Upgrade to Real Account", //"Real Account Required",
                    //     subtitle: AppLocalizations.of(context)!.upgrade_real_account_msg,
                    //     // "This feature requires a verified real account. "
                    //     // "Please convert your demo account to a real account to access all features.",
                    //     noButtonTitle: AppLocalizations.of(context)!.upgrade_real_account_later,//"Not Now",
                    //     yesButtonTitle: AppLocalizations.of(context)!.upgrade_real_account_now, //"Upgrade Now",
                    //     onNoPress: () async {
                    //       Navigator.pop(context);
                    //     },
                    //     onYesPress: () async {
                    //       // All verifications passed

                    //       Navigator.pop(context);
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => const SettingScreen(),
                    //         ),
                    //       );
                    //     },
                    //   );
                    //   return;
                    // }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPersonalInfoScreen(),
                      ),
                    );
                  },
                  isSecondIcon: false,
                ),
                // _isRealAccount ? SizedBox.shrink() :
                _buildDivider(),
                BuildSettingCard(
                  title: AppLocalizations.of(
                    context,
                  )!
                      .settings_language, //"Language Settings",
                  subtitle: AppLocalizations.of(
                    context,
                  )!
                      .settings_language_desc, //"Select your preferred language for the app.",
                  iconString: "assets/svg/lang_icon.svg",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LanguageScreen(),
                      ),
                    );
                  },
                  isSecondIcon: false,
                ),
                _isRealAccount ? SizedBox.shrink() : _buildDivider(),
                _isRealAccount
                    ? SizedBox.shrink()
                    : SwitchAccountCard(
                        title: AppLocalizations.of(
                          context,
                        )!
                            .settings_switch, //"Switch",
                        subtitle: AppLocalizations.of(
                          context,
                        )!
                            .settings_switch_desc, //"Switch Demo user to Real",
                        iconString: "assets/svg/user_icon.svg",
                        isSecondIcon: true,
                        initialSwitchValue: _isRealAccount,
                        onTap: () {
                          debugPrint("Switch card tapped");
                        },
                        onToggleChanged: _onToggleChanged,
                      ),
                if (!Platform.isAndroid) _buildDivider(),
                if (Platform.isIOS)
                  BuildSettingCard(
                    title: AppLocalizations.of(context)!.faceid_enable,//"Enable Face ID",
                    subtitle: AppLocalizations.of(context)!.faceid_desc,//"Use Face ID for quick and secure access.",
                    iconString: "assets/svg/faceId_icon.svg",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FaceIDScreen(),
                        ),
                      );
                    },
                    isSecondIcon: true,
                  ),
                  if (!Platform.isIOS) _buildDivider(),
                //if (CommonService.hasFingerHardWare == true) 
                //_buildDivider(),
                // if (CommonService.hasFingerHardWare == true)
                  if (Platform.isAndroid)
                  BuildSettingCard(
                    title: AppLocalizations.of(
                      context,
                    )!
                        .settings_biometric, //"Enable Biometric Login",
                    subtitle: AppLocalizations.of(
                      context,
                    )!
                        .settings_biometric_desc, //"Log in securely using Touch ID or fingerprint."
                    iconString: "assets/svg/fingerprint_icon.svg",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BiometricScreen(),
                        ),
                      );
                    },
                    isSecondIcon: true,
                  ),
                _buildDivider(),
                BuildSettingCard(
                  title: AppLocalizations.of(
                    context,
                  )!
                      .settings_timezone, //"Timezone",
                  subtitle: AppLocalizations.of(
                    context,
                  )!
                      .settings_timezone_desc, //"Adjust your timezone to match your location.",
                  iconString: "assets/svg/timezone_icon.svg",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TimezoneScreen(),
                      ),
                    );
                  },
                  isSecondIcon: false,
                ),
                _buildDivider(),
                BuildSettingCard(
                  title: AppLocalizations.of(
                    context,
                  )!
                      .settings_password, //"Password Settings",
                  subtitle: AppLocalizations.of(
                    context,
                  )!
                      .settings_password_desc, //"Update or change your account password.",
                  iconString: "assets/svg/password_icon.svg",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                  isSecondIcon: false,
                ),
                _buildDivider(),
                BuildSettingCard(
                  title: AppLocalizations.of(
                    context,
                  )!
                      .settings_delete, //"Delete Account",
                  subtitle: AppLocalizations.of(
                    context,
                  )!
                      .settings_delete_desc, //"Delete your account",
                  iconString: "assets/svg/user_icon.svg",
                  onTap: () async {
                    await genericPopUpWidget(
                      context: context,
                      heading: AppLocalizations.of(
                        context,
                      )!
                          .settings_delete, //"Delete Account",
                      // subtitle: //AppLocalizations.of(context)!.settings_delete,
                      //     "Warning: Deleting your account is permanent. All of your data will be permanently erased and cannot be restored. Are you sure you want to continue?",
                      // noButtonTitle: "Cancel",
                      // yesButtonTitle: "Delete Account",
                      subtitle: //AppLocalizations.of(context)!.settings_delete,
                          AppLocalizations.of(
                        context,
                      )!
                              .delete_account_warning,
                      noButtonTitle: AppLocalizations.of(context)!.cancel,
                      yesButtonTitle: AppLocalizations.of(
                        context,
                      )!
                          .delete_account_title,
                      isLoadingState: ref.watch(authProvider).isButtonState,
                      onNoPress: () {
                        Navigator.pop(context);
                      },
                      onYesPress: () async {
                        /// delete user account
                        await ref.read(authProvider.notifier).deleteUserAccount(
                              context: context,
                            );
                        await LocalDatabase.instance.clearAllUserData();
                      },
                    );
                  },
                  isSecondIcon: false,
                ),
                _buildDivider(),
                BuildSettingCard(
                  title: AppLocalizations.of(
                    context,
                  )!
                      .settings_logout, //"Logout",
                  subtitle: AppLocalizations.of(
                    context,
                  )!
                      .settings_logout_desc, //"Sign out of your account securely.",
                  iconString: "assets/svg/logout_color_icon.svg",
                  onTap: () async {
                    final userId = await LocalDatabase.instance
                        .getUserId(); // pre-fetch here

                    if (!context.mounted) return;

                    await genericPopUpWidget(
                      context: context,
                      heading: AppLocalizations.of(
                        context,
                      )!
                          .logout_popup_title, //"Are you sure you want to logout?",
                      subtitle: AppLocalizations.of(
                        context,
                      )!
                          .logout_popup_desc, //"You will be logged out of your account.",
                      noButtonTitle: AppLocalizations.of(
                        context,
                      )!
                          .logout_no, //"NO",
                      yesButtonTitle: AppLocalizations.of(
                        context,
                      )!
                          .logout_yes, //"YES",
                      isLoadingState: false,
                      onNoPress: () {
                        Navigator.pop(context);
                      },
                      onYesPress: () async {
                        await authStateReadProvider.logoutUser(
                          context: context,
                          userId: userId!,
                        );
                      },
                    );
                  },
                  isSecondIcon: false,
                ),
                _buildDivider(),

                GetGenericText(
                  text:
                      "Version $appVersion-${environment == "production" ? "live" : "staging"}",
                  // "v1.0.0-${environment == "production" ? "live" : "staging"}",
                  fontSize: sizes!.responsiveFont(phoneVal: 11, tabletVal: 13),
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey3Color,
                ),
              ],
            ).get16HorizontalPadding(),
          ),
        ),
      ),
    );
  }

  // build divider
  Widget _buildDivider() {
    return Column(
      children: [
        ConstPadding.sizeBoxWithHeight(height: 12),
        Divider(
          color: AppColors.greyScale900,
          thickness: 1.5,
        ),
        ConstPadding.sizeBoxWithHeight(height: 12),
      ],
    );
  }
}
