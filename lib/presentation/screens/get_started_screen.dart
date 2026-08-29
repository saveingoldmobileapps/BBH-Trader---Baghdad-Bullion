import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/al_taif_bank_kyc/native/bbh_native_onboarding_screen.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/register_screen.dart';
import 'package:baghdad_bullion_house/presentation/screens/setting_screens/support_screen.dart';
import 'package:baghdad_bullion_house/presentation/sharedProviders/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'auth_screens/login_screen.dart';

class GetStartedScreen extends ConsumerStatefulWidget {
  const GetStartedScreen({super.key});

  @override
  ConsumerState createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends ConsumerState<GetStartedScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    final gradient = AppColors.brandGoldGradient;
    sizes!.refreshSize(context);
    final languageState = ref.watch(languageProvider);
    bool isEnglish = languageState.languageCode == "en";
    final languageNotifier = ref.read(languageProvider.notifier);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          debugPrint('Route popped with result: $result');
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.confirm_exit),
              content: Text(AppLocalizations.of(context)!.sure_exit),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.yes),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.no),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background Container
            Container(
              height: sizes!.height,
              width: sizes!.width,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/png/bg_start.png'),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Language Switch (Top Right)
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.eng_title,
                                        style: TextStyle(
                                          color: isEnglish
                                              ? Colors.white
                                              : Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Switch.adaptive(
                                        activeThumbColor:
                                            AppColors.primaryGold500,
                                        activeTrackColor: AppColors
                                            .primaryGold500
                                            .withValues(alpha: 0.35),
                                        value: !isEnglish,
                                        onChanged: (_) {
                                          languageNotifier.toggleLanguage(
                                            context,
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.arabic_title,
                                        style: TextStyle(
                                          color: !isEnglish
                                              ? Colors.white
                                              : Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// Logo
                                Center(
                                  child: Image.asset(
                                    "assets/png/app_ic.png",
                                    height: 200,
                                    width: 200,
                                    fit: BoxFit.contain,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                /// Title
                                Text(
                                  AppLocalizations.of(context)!.your_gold,
                                  textAlign:
                                      Directionality.of(context) ==
                                          TextDirection.rtl
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  style: AppFonts.text(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                /// Subtitle
                                Text(
                                  AppLocalizations.of(context)!.login_des,
                                  textAlign:
                                      Directionality.of(context) ==
                                          TextDirection.rtl
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  style: AppFonts.text(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white70,
                                    
                                  ),
                                ),
                                const SizedBox(height: 14),

                                /// Secondary Button - Login
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xff74540E),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.login_to_bbh,
                                      style:  TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.whiteColor,
                                        fontFamily: isEnglish? AppFonts.english:AppFonts.arabic,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                /// Primary Button - Sign Up
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const RegisterScreen(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: gradient,
                                        // const LinearGradient(
                                        //   colors: [
                                        //     Color(0xffB19454),
                                        //     Color(0xff74540E),
                                        //   ],
                                        //   begin: Alignment.topLeft,
                                        //   end: Alignment.bottomRight,
                                        // ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.register_for_free_demo, //.sign_up_bbh,
                                          style:  TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                            fontFamily: isEnglish? AppFonts.english:AppFonts.arabic,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                /// Bank client onboarding (native Flutter flow)
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xff74540E),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const BbhNativeOnboardingScreen(),
                                        ),
                                      );
                                    },
                                    // icon: const Icon(
                                    //   Icons.account_balance_rounded,
                                    //   color: AppColors.whiteColor,
                                    //   size: 22,
                                    // ),
                                    label: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.open_real_account, //bank_client_onboarding,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.whiteColor,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 100,
                                ), // Extra space for FAB
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            /// Floating Action Button - Bottom Left (Small Sphere)
            Positioned(
              left: isEnglish ? 20 : 0,
              right: isEnglish ? 0 : 20,
              bottom: MediaQuery.of(context).viewPadding.bottom + 16,
              child: Align(
                alignment: isEnglish
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SupportScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppColors.goldDarkColor,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFD4AF37,
                            ).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.support_agent,
                            color:
                                AppColors.primaryGold500, //Color(0xFFD4AF37),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)!.need_help,
                          style: AppFonts.text(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Contact Us Page
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyScale1000,
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.contact_us,
          style: AppFonts.text(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Icon
              Center(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xffB19454), Color(0xff74540E)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.headset_mic,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: Text(
                  AppLocalizations.of(context)!.get_in_touch,
                  style: AppFonts.text(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Center(
                child: Text(
                  AppLocalizations.of(context)!.contact_desc,
                  textAlign: TextAlign.center,
                  style: AppFonts.text(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Email Card
              _buildContactCard(
                context: context,
                icon: Icons.email_outlined,
                title: AppLocalizations.of(context)!.email_us,
                subtitle: 'we.care@baghdadbullionhouse.com',
                color: const Color(0xffB19454),
                //onTap: () async {
                //   final Uri emailUri = Uri(
                //     scheme: 'mailto',
                //     path: 'support@baghdadbullion.com',
                //     query: 'subject=BBH Support Request',
                //   );
                //   if (await canLaunchUrl(emailUri)) {
                //     await launchUrl(emailUri);
                //   }
                // },
                onTap: () async {
                  await CommonService.openEmailApp(
                    emailAddress: "we.care@baghdadbullionhouse.com",
                  );
                },
              ),

              const SizedBox(height: 16),

              // WhatsApp Card
              _buildContactCard(
                context: context,
                icon: Icons.chat_bubble_outline,
                title: AppLocalizations.of(context)!.whatsapp,
                subtitle: "+9647871111112",
                color: const Color(0xff25D366),
                onTap: () async {
                  await CommonService.openWhatsappUrl(
                    phoneNumber: "+9647871111112",
                    message:
                        "Hello, I need an assistance from Baghdad Bullion House Team",
                  );
                },
              ),

              const SizedBox(height: 16),

              // Phone Card
              _buildContactCard(
                context: context,
                icon: Icons.phone_outlined,
                title: AppLocalizations.of(context)!.call_us,
                subtitle: '+964 123 456 789',
                color: Colors.green,
                onTap: () async {
                  final Uri phoneUri = Uri(
                    scheme: 'tel',
                    path: '+964123456789',
                  );
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  }
                },
              ),

              const SizedBox(height: 32),

              // Office Hours
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xff262929),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xff74540E).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: const Color(0xffB19454),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppLocalizations.of(context)!.office_hours,
                          style: AppFonts.text(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.office_hours_desc,
                      style: AppFonts.text(
                        fontSize: 14,
                        color: Colors.white70,
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
}

Widget _buildContactCard({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff262929),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xff74540E).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.text(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppFonts.text(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: color,
            size: 16,
          ),
        ],
      ),
    ),
  );
}
