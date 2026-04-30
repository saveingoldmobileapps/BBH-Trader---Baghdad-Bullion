import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/auth_kyc_screens/kyc_first_step_screen.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/auth_kyc_screens/kyc_second_step_screen.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/email_verify_code_screen.dart';
import 'package:baghdad_bullion_house/presentation/screens/esouq_screens/esouq_screen.dart';
import 'package:baghdad_bullion_house/presentation/screens/gift_fund_screens/gift_fund_screen.dart';
import 'package:baghdad_bullion_house/presentation/screens/my_order_screens/my_order_screen.dart';
import 'package:baghdad_bullion_house/presentation/screens/setting_screens/support_screen.dart';
import 'package:baghdad_bullion_house/presentation/sharedProviders/providers/home_provider.dart';
import 'package:baghdad_bullion_house/presentation/widgets/demo_account_popup.dart'
    show UpgradeAccountPopup;
import 'package:baghdad_bullion_house/presentation/widgets/drawer_screen.dart';
import 'package:baghdad_bullion_house/presentation/widgets/widget_export.dart';
import '../../data/data_sources/local_database/local_database.dart';
import '../screens/alerts/view_alerts.dart';
import '../sharedProviders/providers/auth_provider.dart';

class GetDrawerBar extends ConsumerStatefulWidget {
  final VoidCallback onTap;

  const GetDrawerBar({super.key, required this.onTap});

  @override
  ConsumerState<GetDrawerBar> createState() => _GetDrawerBarState();
}

class _GetDrawerBarState extends ConsumerState<GetDrawerBar> {
  String appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    final environment = dotenv.env['ENVIRONMENT'] ?? 'staging';
    final buildEnvLabel = environment == 'production' ? "LIVE" : "STAGING";
    setState(() {
      appVersion = '${info.version}+${info.buildNumber} ($buildEnvLabel)';
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainStateWatchProvider = ref.watch(homeProvider);
    final authStateReadProvider = ref.read(authProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Drawer(
        backgroundColor: const Color(0xFF121212),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Back arrow
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 16),
                      Text(
                        l10n.more,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // E-SOUQ
                      _buildMenuCard(
                        context,
                        title: l10n.esouq,
                        subtitle: l10n.side_menu_esouq_subtitle,
                        icon: "assets/svg/shop.svg",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EsouqScreen(),
                          ),
                        ),
                      ),

                      // MY ORDERS
                      _buildMenuCard(
                        context,
                        title: l10n.my_orders,
                        subtitle: l10n.side_menu_orders_subtitle,
                        icon: "assets/svg/box.svg",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyOrdersScreen(),
                          ),
                        ),
                      ),

                      // GIFT A FRIEND (With all original logic)
                      _buildMenuCard(
                        context,
                        title: l10n.gift,
                        subtitle: l10n.side_menu_gift_subtitle,
                        icon: "assets/svg/gift.svg",
                        onTap: () => _handleGiftLogic(
                          context,
                          ref,
                          mainStateWatchProvider,
                        ),
                      ),

                      // ALERT
                      _buildMenuCard(
                        context,
                        title: l10n.alert_title,
                        subtitle: l10n.side_menu_alerts_subtitle,
                        icon: "assets/svg/notification.svg",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ActiveAlertsScreen(),
                          ),
                        ),
                      ),

                      // SUPPORT
                      _buildMenuCard(
                        context,
                        title: l10n.support,
                        subtitle: l10n.side_menu_support_subtitle,
                        icon: "assets/svg/support_icon.svg",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupportScreen(),
                          ),
                        ),
                      ),
                      //const SizedBox(height: 10),
                      _buildMenuCard(
                        context,
                        title: l10n.settings,
                        subtitle: l10n.side_menu_settings_subtitle,
                        icon: "assets/svg/setting_icon.svg",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DrawerScreen(),
                          ),
                        ),
                      ),

                      // LOGOUT
                      _buildMenuCard(
                        context,
                        title: l10n.logout,
                        subtitle: l10n.side_menu_logout_subtitle,
                        icon: "assets/svg/logout_icon.svg",
                        onTap: () => _handleLogout(
                          context,
                          ref,
                          authStateReadProvider,
                          l10n,
                        ),
                      ),

                     // const SizedBox(height: 10),

                      // APP VERSION FOOTER
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10,
                          ),
                          child: Text(
                            'App Version: $appVersion',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF353530),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  icon,
                  height: 24,
                  width: 24,
                  color: AppColors.goldColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleGiftLogic(
    BuildContext context,
    WidgetRef ref,
    dynamic mainProvider,
  ) async {
    final db = LocalDatabase.instance;
    final isDemo = await db.getIsDemo() ?? false;
    if (isDemo) {
      if (!context.mounted) return;
      await UpgradeAccountPopup.show(context: context, ref: ref);
      return;
    }

    final isEmailVerified = await db.getIsEmailVerified() ?? false;
    final isBasicKyc = await db.getIsUserBasicKycVerified() ?? false;
    final isFullKyc = await db.getIsUserBasicKycVerified() ?? false;
    final tempCredit = await db.getIsUsertemporaryCreditStatus() ?? false;

    if (!context.mounted) return;

    if (tempCredit) {
      await temporaryCreditPopUpWidget(
        context: context,
        heading: AppLocalizations.of(context)!.temporary_credit_title,
        subtitle: AppLocalizations.of(context)!.temporary_credit_message,
        buttonTitle: AppLocalizations.of(
          context,
        )!.temporary_credit_contact_support,
        icon: Icons.card_giftcard,
        onButtonPress: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SupportScreen()),
          );
        },
        oncloseButtonPress: () => Navigator.pop(context),
      );
      return;
    }

    if (!isEmailVerified) {
      _showKycPopup(context, "email", mainProvider.userEmail);
      return;
    }
    if (!isBasicKyc) {
      _showKycPopup(context, "residency", "");
      return;
    }
    if (!isFullKyc) {
      _showKycPopup(context, "kyc", "");
      return;
    }

    if (mainProvider.getHomeFeedResponse.payload != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GiftFundScreen(
            walletExists:
                mainProvider.getHomeFeedResponse.payload!.walletExists!,
          ),
        ),
      );
    }
  }

  void _showKycPopup(BuildContext context, String type, String email) {
    final l10n = AppLocalizations.of(context)!;
    genericPopUpWidget(
      isLoadingState: false,
      context: context,
      heading: type == "email"
          ? l10n.email_verification_required
          : (type == "residency"
                ? l10n.residency_document_required
                : l10n.kyc_verification_required),
      subtitle: type == "email"
          ? l10n.email_verification_message
          : (type == "residency"
                ? l10n.residency_verification_message
                : l10n.kyc_verification_message),
      noButtonTitle: l10n.later,
      yesButtonTitle: l10n.proceed,
      onNoPress: () => Navigator.pop(context),
      onYesPress: () async {
        Navigator.pop(context);
        Widget screen = type == "email"
            ? EmailVerifyCodeScreen(email: email)
            : (type == "residency"
                  ? KycFirstStepScreen()
                  : KycSecondStepScreen());
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
    );
  }

  Future<void> _handleLogout(
    BuildContext context,
    WidgetRef ref,
    dynamic authNotifier,
    dynamic l10n,
  ) async {
    final userId = await LocalDatabase.instance.getUserId();
    if (!context.mounted) return;
    await genericPopUpWidget(
      context: context,
      heading: l10n.logout_popup_title,
      subtitle: l10n.logout_popup_desc,
      noButtonTitle: l10n.logout_no,
      yesButtonTitle: l10n.logout_yes,
      isLoadingState: false,
      onNoPress: () => Navigator.pop(context),
      onYesPress: () async {
        await authNotifier.logoutUser(context: context, userId: userId!);
      },
    );
  }
}
