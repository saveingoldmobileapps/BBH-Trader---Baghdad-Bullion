import 'package:baghdad_bullion_house/presentation/screens/auth_screens/al_taif_bank_kyc/on_board_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/register_screen.dart';
import 'package:baghdad_bullion_house/presentation/sharedProviders/providers/language_provider.dart';
import 'auth_screens/login_screen.dart';

class GetStartedScreen extends ConsumerStatefulWidget {
  const GetStartedScreen({super.key});

  @override
  ConsumerState createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends ConsumerState<GetStartedScreen> {
  DateTime? lastPressed;

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
    /// Refresh sizes on orientation change
    sizes!.refreshSize(context);
    final languageState = ref.watch(languageProvider);
    bool isEnglish = languageState.languageCode == "en";

    /// states
    //final languageState = ref.watch(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          // Handle the result from the popped route
          debugPrint('Route popped with result: $result');
        } else {
          // Show a confirmation dialog before allowing the pop
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Confirm Exit'),
              content: Text('Are you sure you want to exit?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Pop the route
                  },
                  child: Text('Yes'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: Text('No'),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
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
                          AppLocalizations.of(context)!.eng_title,//"English",
                          style: TextStyle(
                            color: isEnglish ? Colors.white : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Switch.adaptive(
                          activeThumbColor: AppColors.primaryGold500,
                          activeTrackColor: AppColors.primaryGold500.withValues(alpha: 0.35),
                          value: !isEnglish,
                          onChanged: (_) {
                            languageNotifier.toggleLanguage(context);
                          },
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(context)!.arabic_title,//"العربية",
                          style: TextStyle(
                            color: !isEnglish ? Colors.white : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  /// Logo
                  Center(
                    child: Container(
                      height: 250,
                      width: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          image: AssetImage(
                            "assets/png/app_ic.png",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// Title
                  Text(
                    AppLocalizations.of(context)!.your_gold, //"Your Gold\nYour Wealth.",
                    textAlign: Directionality.of(context) == TextDirection.rtl?TextAlign.right:TextAlign.left,
                    style: GoogleFonts.roboto(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Subtitle
                  Text(
                    AppLocalizations.of(context)!.login_des,
                    textAlign: Directionality.of(context) == TextDirection.rtl?TextAlign.right:TextAlign.left,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),

                  const Spacer(flex: 1),

                  /// Primary Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xffB19454),
                              Color(0xff74540E),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.sign_up_bbh, //"I'm new to B&H",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// Secondary Button
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
                        AppLocalizations.of(context)!.login_to_bbh, // "I'm an existing user",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),
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
                            builder: (_) => const OnboardingScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.account_balance_rounded,
                        color: AppColors.whiteColor,
                        size: 22,
                      ),
                      label: Text(
                        AppLocalizations.of(context)!.bank_client_onboarding,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteColor,
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
    );
  }
}
