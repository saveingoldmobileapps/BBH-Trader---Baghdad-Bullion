import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saveingold_fzco/presentation/widgets/image_oval_widget.dart';

import '../../core/theme/const_colors.dart';
import '../../data/data_sources/local_database/local_database.dart';
import '../../l10n/app_localizations.dart';
import '../screens/setting_screens/biometric_screen.dart';
import '../screens/setting_screens/change_password_screen.dart';
import '../screens/setting_screens/edit_personal_info_screen.dart';
import '../screens/setting_screens/language_screen.dart';
import '../sharedProviders/providers/auth_provider.dart';
import '../sharedProviders/providers/home_provider.dart';
import 'pop_up_widget.dart';

class DrawerScreen extends ConsumerStatefulWidget {
  const DrawerScreen({super.key});

  @override
  ConsumerState<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends ConsumerState<DrawerScreen> {
  @override
  Widget build(BuildContext context) {
    // ✅ You can safely watch/read providers here
    final mainStateWatchProvider = ref.watch(homeProvider);
    final authStateReadProvider = ref.read(authProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.greyScale1000,
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        // title: GetGenericText(
        //   text: AppLocalizations.of(context)!.biometric_title,
        //   fontSize: sizes!.responsiveFont(phoneVal: 20, tabletVal: 24),
        //   fontWeight: FontWeight.w400,
        //   color: AppColors.grey6Color,
        // ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Back Button
          // Padding(
          //   padding: const EdgeInsets.all(16),
          //   child: GestureDetector(
          //     onTap: () => Navigator.pop(context),
          //     child: const Icon(
          //       Icons.arrow_back_ios_new,
          //       color: Colors.white,
          //     ),
          //   ),
          // ),

          /// Profile Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                FutureBuilder<String?>(
                  future: LocalDatabase.instance.getUserProfileImage(),
                  builder: (context, snapshot) {
                    final imagePath = snapshot.data ?? '';

                    return SquircleProfileImage(
                      imagePath: imagePath,
                      size: 80,
                      radius: 20, // 🔥 matches your example image
                    );
                  },
                ),
                const SizedBox(width: 12),
                FutureBuilder<List<String?>>(
                  future: Future.wait([
                    LocalDatabase.instance.getUserName(),
                    LocalDatabase.instance.getUserAccountId(),
                  ]),
                  builder: (context, snapshot) {
                    final cachedName = snapshot.data?[0] ?? '';
                    final cachedId = snapshot.data?[1] ?? '';

                    final networkName =
                        mainStateWatchProvider
                            .getUserProfileResponse
                            .payload
                            ?.userProfile
                            ?.firstName
                            ?.en ??
                        '';

                    final networkId =
                        mainStateWatchProvider
                            .getUserProfileResponse
                            .payload
                            ?.userProfile
                            ?.accountId ??
                        '';

                    final finalName = networkName.isNotEmpty
                        ? networkName
                        : cachedName;

                    final finalAccountId = networkId.isNotEmpty
                        ? networkId
                        : cachedId;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// User Name
                        Text(
                          finalName.isNotEmpty ? finalName : '—',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 4),

                        /// Account ID (with @)
                        Text(
                          finalAccountId.isNotEmpty ? '@$finalAccountId' : '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _settingTile(
                  icon: "assets/svg/profile.svg",
                  title: "Personal Information",
                  subtitle: "Manage your personal details",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditPersonalInfoScreen(),
                      ),
                    );
                  },
                ),

                _settingTile(
                  icon: "assets/svg/language_circle.svg",
                  title: "Language Settings",
                  subtitle: "Select your preferred language",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LanguageScreen(),
                      ),
                    );
                  },
                ),

                if (Platform.isAndroid)
                  _settingTile(
                    icon: "assets/svg/finger_scan.svg",
                    title: "Enable Biometric Login",
                    subtitle: "Login securely using Touch ID or fingerprint",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BiometricScreen(),
                        ),
                      );
                    },
                  ),

                _settingTile(
                  icon: "assets/svg/lock.svg",
                  title: "Passcode Settings",
                  subtitle: "Update or change your account passcode",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),

                _settingTile(
                  icon: "assets/svg/profile_delete.svg",
                  title: "Delete Account",
                  subtitle: "Delete your account and all its data",
                  isDanger: true,
                  onTap: () async {
                    await genericPopUpWidget(
                      context: context,
                      heading: AppLocalizations.of(
                        context,
                      )!.settings_delete,
                      subtitle: AppLocalizations.of(
                        context,
                      )!.delete_account_warning,
                      noButtonTitle: AppLocalizations.of(context)!.cancel,
                      yesButtonTitle: AppLocalizations.of(
                        context,
                      )!.delete_account_title,
                      isLoadingState: ref.watch(authProvider).isButtonState,
                      onNoPress: () {
                        Navigator.pop(context);
                      },
                      onYesPress: () async {
                        await ref
                            .read(authProvider.notifier)
                            .deleteUserAccount(context: context);

                        await LocalDatabase.instance.clearAllUserData();
                      },
                    );
                  },
                ),

                _settingTile(
                  icon: "assets/svg/logout.svg",
                  title: "Logout",
                  subtitle: "Log out of your account",
                  isDanger: true,
                  onTap: () async {
                    final userId = await LocalDatabase.instance
                        .getUserId(); // pre-fetch here

                    if (!context.mounted) return;
                    await genericPopUpWidget(
                      context: context,
                      heading: AppLocalizations.of(
                        context,
                      )!.logout_popup_title, //"Are you sure you want to logout?",
                      subtitle: AppLocalizations.of(
                        context,
                      )!.logout_popup_desc, //"You will be logged out of your account.",
                      noButtonTitle: AppLocalizations.of(
                        context,
                      )!.logout_no, //"NO",
                      yesButtonTitle: AppLocalizations.of(
                        context,
                      )!.logout_yes, //"YES",
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Single Setting Card (UNCHANGED)
  Widget _settingTile({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF262929),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xff353530),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
