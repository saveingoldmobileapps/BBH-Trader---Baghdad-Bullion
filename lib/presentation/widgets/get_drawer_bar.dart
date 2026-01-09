import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/auth_kyc_screens/kyc_first_step_screen.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/auth_kyc_screens/kyc_second_step_screen.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/email_verify_code_screen.dart';
import 'package:saveingold_fzco/presentation/screens/esouq_screens/esouq_screen.dart';
import 'package:saveingold_fzco/presentation/screens/gift_fund_screens/gift_fund_screen.dart';
import 'package:saveingold_fzco/presentation/screens/my_order_screens/my_order_screen.dart';
import 'package:saveingold_fzco/presentation/screens/setting_screens/support_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/home_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/demo_account_popup.dart'
    show UpgradeAccountPopup;
import 'package:saveingold_fzco/presentation/widgets/drawer_screen.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

import '../../data/data_sources/local_database/local_database.dart';
import '../screens/alerts/view_alerts.dart';
import '../sharedProviders/providers/auth_provider.dart';

class GetDrawerBar extends ConsumerWidget {
  final VoidCallback onTap;

  const GetDrawerBar({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, ref) {
    final mainStateWatchProvider = ref.watch(homeProvider);
    final authStateReadProvider = ref.read(authProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: MediaQuery.of(context).size.width, // Full screen width
      child: Drawer(
        backgroundColor: const Color(0xFF121212), // Dark theme background
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section with Back arrow and "More"
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onTap,
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
                        l10n.more ?? "More",
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
                        subtitle: "Shop online for the best deals",
                        icon: "assets/svg/shop.svg",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EsouqScreen(),
                          ),
                        ),
                      ),

                      // MY ORDERS
                      _buildMenuCard(
                        context,
                        title: l10n.my_orders,
                        subtitle: "Track your orders and manage them",
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
                        subtitle: "Send a gift to a friend",
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
                        subtitle:
                            "Get notified when the price of gold reaches your target",
                        icon: "assets/svg/notification.svg",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ActiveAlertsScreen(),
                          ),
                        ),
                      ),

                      // REQUEST LOAN (Placeholder for functionality)
                      _buildMenuCard(
                        context,
                        title: "Request loan",
                        subtitle: "Apply for a loan",
                        icon: "assets/svg/bank.svg",
                        onTap: () {},
                      ),

                      // SUPPORT
                      _buildMenuCard(
                        context,
                        title: l10n.support,
                        subtitle: "Contact our support team",
                        icon: "assets/svg/support_icon.svg",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupportScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildMenuCard(
                        context,
                        title: l10n.settings,
                        subtitle: "Manage your account and app preferences",
                        icon: "assets/svg/setting_icon.svg",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DrawerScreen(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // LOGOUT
                      _buildMenuCard(
                        context,
                        title: l10n.logout,
                        subtitle: "Log out of your account",
                        icon: "assets/svg/logout_icon.svg",
                        onTap: () => _handleLogout(
                          context,
                          ref,
                          authStateReadProvider,
                          l10n,
                        ),
                      ),

                      const SizedBox(height: 40),
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

  // Helper to build the stylized card from the image
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
            color: const Color(0xFF1E1E1E), // Darker grey card
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

  // --- LOGIC FUNCTIONS (STAYING TRUE TO YOUR ORIGINAL CODE) ---

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
    final isFullKyc =
        await db.getIsUserBasicKycVerified() ??
        false; // Fixed from your code logic
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
            MaterialPageRoute(builder: (context) => const SupportScreen()),
          );
        },
        oncloseButtonPress: () => Navigator.pop(context),
      );
      return;
    }

    // KYC Chain logic from your original snippet
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

    // Navigation if all passed
    if (mainProvider.getHomeFeedResponse.payload != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GiftFundScreen(
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
      subtitle: l10n.residency_verification_message,
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
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
