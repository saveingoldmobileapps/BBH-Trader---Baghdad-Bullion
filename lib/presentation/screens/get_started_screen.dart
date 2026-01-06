import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/register_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/language_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../data/data_sources/local_database/local_database.dart';
import '../../data/data_sources/local_database/secure_database.dart';
import '../sharedProviders/providers/auth_provider.dart';
import 'auth_screens/login_screen.dart';

class GetStartedScreen extends ConsumerStatefulWidget {
  final bool? autoLogin;

  const GetStartedScreen({
    super.key,
    this.autoLogin,
  });

  @override
  ConsumerState createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends ConsumerState<GetStartedScreen> {
  DateTime? lastPressed;

  @override
  void initState() {
    // TODO: implement initState

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.autoLogin == true) {
        _handleAutoLogin();
      }
    });
    super.initState();
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

  /// auto login
  Future<void> _handleAutoLogin() async {
    debugPrint("Starting auto-login...");
    _showLoadingIndicator();

    final refreshToken = await SecureStorageService.instance.getRefreshToken();
    final isAutoLoginEnabled = await LocalDatabase.instance.getAutoLogin();

    debugPrint(
      "Auto-login data - RefreshToken: $refreshToken | Enabled: $isAutoLoginEnabled",
    );

    try {
      if (refreshToken != null && isAutoLoginEnabled == true) {
        debugPrint("inside auto-login...");
        if (!mounted) return;

        final authNotifier = ref.read(authProvider.notifier);
        bool loginSuccess = await authNotifier.userLoginWithToken(
          context: context,
        );

        if (!loginSuccess) {
          debugPrint("Auto-login failed");
        }
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint("Auto-login error: $e");
    } finally {
      if (mounted) _hideLoadingIndicator(); // Always hides loader
    }
  }

  void _showLoadingIndicator() {
    // Show dialog asynchronously and continue
    Future.microtask(() {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.whiteColor),
          ),
        ),
      );
    });
  }

  /// Hides loading indicator dialog if shown
  void _hideLoadingIndicator() {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
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

    /// Determine the direction of the arrow based on the current locale
    bool isRtl = languageNotifier.isRtl();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          // Handle the result from the popped route
          debugPrint('Route popped with result: $result');
        } else {
          // Show a confirmation dialog before allowing the pop
          showDialog(
            context: result as BuildContext,
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
                          "English",
                          style: TextStyle(
                            color: isEnglish ? Colors.white : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Switch.adaptive(
                          activeColor: AppColors.primaryGold500,
                          value: !isEnglish,
                          onChanged: (_) {
                            languageNotifier.toggleLanguage(context);
                          },
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "العربية",
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
                            "assets/png/main_logo.png",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// Title
                  Text(
                    "Your Gold\nYour Wealth.",
                    textAlign: TextAlign.left,
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
                    AppLocalizations.of(context)!.gs_subtitle,
                    textAlign: TextAlign.left,
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
                        child: const Center(
                          child: Text(
                            "I'm new to B&H",
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
                        "I'm an existing user",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
