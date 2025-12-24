import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
            child: sizes!.isLandscape()
                ? Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstPadding.sizeBoxWithHeight(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "English",
                            style: TextStyle(
                              color: isEnglish ? Colors.white : Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch.adaptive(
                            activeColor: AppColors.primaryGold500,
                            value: !isEnglish, // true = Arabic
                            onChanged: (value) {
                              languageNotifier.toggleLanguage(context);
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "العربية",
                            style: TextStyle(
                              color: !isEnglish ? Colors.white : Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Align(
                        alignment: isRtl
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    '${AppLocalizations.of(context)!.track}${sizes!.isPhone ? '\n' : ' '}',
                                // text: 'Track${sizes!.isPhone ? '\n' : ' '}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: sizes!.isPhone
                                      ? isRtl
                                            ? sizes!.fontRatio * 90
                                            : sizes!.fontRatio * 95
                                      : isRtl
                                      ? sizes!.fontRatio * 146
                                      : sizes!.fontRatio * 158,
                                  fontFamily: GoogleFonts.roboto().fontFamily,
                                  fontWeight: FontWeight.w300,
                                  height: 0.9,
                                ),
                              ),
                              TextSpan(
                                text: AppLocalizations.of(context)!.gold,
                                // text: 'Gold',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: sizes!.isPhone
                                      ? isRtl
                                            ? sizes!.fontRatio * 90
                                            : sizes!.fontRatio * 95
                                      : isRtl
                                      ? sizes!.fontRatio * 146
                                      : sizes!.fontRatio * 158,
                                  fontFamily: GoogleFonts.roboto().fontFamily,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: '.${sizes!.isPhone ? '\n' : '  '}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: sizes!.isPhone
                                      ? sizes!.fontRatio * 98
                                      : sizes!.fontRatio * 158,
                                  fontFamily: GoogleFonts.roboto().fontFamily,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              TextSpan(
                                text:
                                    '${AppLocalizations.of(context)!.build}${sizes!.isPhone ? '\n' : ' '}',
                                // text: 'Build\n',
                                // text: 'Build${sizes!.isPhone ? '\n' : ' '}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: sizes!.isPhone
                                      ? isRtl
                                            ? sizes!.fontRatio * 86
                                            : sizes!.fontRatio * 95
                                      : isRtl
                                      ? sizes!.fontRatio * 146
                                      : sizes!.fontRatio * 158,
                                  fontFamily: GoogleFonts.roboto().fontFamily,
                                  fontWeight: FontWeight.w500,
                                  height: 0.9,
                                ),
                              ),
                              TextSpan(
                                text: AppLocalizations.of(context)!.wealth,
                                // text: 'Wealth',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: sizes!.isPhone
                                      ? isRtl
                                            ? sizes!.fontRatio * 86
                                            : sizes!.fontRatio * 95
                                      : isRtl
                                      ? sizes!.fontRatio * 146
                                      : sizes!.fontRatio * 158,
                                  fontFamily: GoogleFonts.roboto().fontFamily,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: '.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isRtl
                                      ? sizes!.fontRatio * 146
                                      : sizes!.fontRatio * 158,
                                  fontFamily: GoogleFonts.roboto().fontFamily,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Align(
                        alignment: isRtl
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: GetGenericText(
                          text: //AppLocalizations.of(context)!.gs_subtitle,
                              "Seamlessly buy, sell, and grow your gold portfolio with the platform you trust.",
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),

                      // ConstPadding.sizeBoxWithHeight(height: 24),
                      const Spacer(),

                      /// Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // login button
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: sizes!.width / 2.25,
                              height: sizes!.heightRatio * 84,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: GetGenericText(
                                  text: AppLocalizations.of(
                                    context,
                                  )!.login, //"Login",
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryGold500,
                                ),
                              ),
                            ),
                          ),

                          // get started button
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: sizes!.width / 2.25,
                              height: sizes!.heightRatio * 84,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment(1.00, 0.01),
                                  end: Alignment(-1, -0.01),
                                  colors: [
                                    Color(0xFFBBA473),
                                    Color(0xFF675A3D),
                                  ],
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isRtl)
                                    SvgPicture.asset(
                                      'assets/svg/forward_arrow.svg',
                                      height: sizes!.heightRatio * 32,
                                      width: sizes!.widthRatio * 32,
                                    ),
                                  GetGenericText(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.getStarted,
                                    //"Get Started",
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  ConstPadding.sizeBoxWithWidth(width: 6),
                                  if (!isRtl)
                                    SvgPicture.asset(
                                      'assets/svg/forward_arrow.svg',
                                      height: sizes!.heightRatio * 32,
                                      width: sizes!.widthRatio * 32,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ).getHorizontalPadding(padding: 40)
                : Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstPadding.sizeBoxWithHeight(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "English",
                            style: TextStyle(
                              color: isEnglish ? Colors.white : Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch.adaptive(
                            activeColor: AppColors.primaryGold500,
                            value: !isEnglish, // true = Arabic
                            onChanged: (value) {
                              languageNotifier.toggleLanguage(context);
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "العربية",
                            style: TextStyle(
                              color: !isEnglish ? Colors.white : Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      // ElevatedButton(
                      //   onPressed: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (_) =>
                      //               const BuyPhysicalGoldFormScreen()),
                      //     );
                      //   },
                      //   child: const Text("Buy Physical Gold"),
                      // ),
                      const Spacer(),
                      // ConstPadding.sizeBoxWithHeight(height: 70),
                      Align(
                        alignment: isRtl
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    "${AppLocalizations.of(context)!.track}\n",
                                // text: 'Track\n',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: sizes!.isPhone
                                      ? isRtl
                                            ? sizes!.fontRatio * 90
                                            : sizes!.fontRatio * 102
                                      : isRtl
                                      ? sizes!.fontRatio * 146
                                      : sizes!.fontRatio * 158,
                                  fontFamily: GoogleFonts.roboto().fontFamily,
                                  fontWeight: FontWeight.w300,
                                  height: 0.9,
                                ),
                              ),
                              TextSpan(
                                text: AppLocalizations.of(context)!.gold,
                                // text: 'Gold',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: sizes!.isPhone
                                      ? isRtl
                                            ? sizes!.fontRatio * 90
                                            : sizes!.fontRatio * 102
                                      : isRtl
                                      ? sizes!.fontRatio * 146
                                      : sizes!.fontRatio * 158,
                                  fontFamily: GoogleFonts.roboto().fontFamily,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: '.\n',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: sizes!.isPhone
                                      ? isRtl
                                            ? sizes!.fontRatio * 86
                                            : sizes!.fontRatio * 98
                                      : isRtl
                                      ? sizes!.fontRatio * 146
                                      : sizes!.fontRatio * 158,
                                  // ? sizes!.fontRatio * 98
                                  // : sizes!.fontRatio * 158,
                                  fontFamily: GoogleFonts.roboto().fontFamily,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              TextSpan(
                                text:
                                    "${AppLocalizations.of(context)!.build}\n",
                                // text: 'Build\n',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: sizes!.isPhone
                                      ? isRtl
                                            ? sizes!.fontRatio * 70
                                            : sizes!.fontRatio * 80
                                      : isRtl
                                      ? sizes!.fontRatio * 148
                                      : sizes!.fontRatio * 158,
                                  fontFamily: GoogleFonts.roboto().fontFamily,
                                  fontWeight: FontWeight.w300,
                                  height: 0.9,
                                ),
                              ),
                              TextSpan(
                                text: AppLocalizations.of(context)!.wealth,
                                // text: 'Wealth',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: sizes!.isPhone
                                      ? isRtl
                                            ? sizes!.fontRatio * 86
                                            : sizes!.fontRatio * 98
                                      : isRtl
                                      ? sizes!.fontRatio * 146
                                      : sizes!.fontRatio * 158,
                                  // ? sizes!.fontRatio * 98
                                  // : sizes!.fontRatio * 158,
                                  fontFamily: GoogleFonts.roboto().fontFamily,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ConstPadding.sizeBoxWithHeight(height: 14),
                      isRtl
                          ? GetGenericText(
                              text: AppLocalizations.of(context)!.gs_subtitle,
                              fontSize: sizes!.isPhone ? 10 : 22,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ).getAlignRight()
                          : GetGenericText(
                              text: AppLocalizations.of(context)!.gs_subtitle,
                              fontSize: sizes!.isPhone ? 16 : 22,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ).getAlign(),

                      const Spacer(),

                      /// Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // login button
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: sizes!.isPhone
                                  ? sizes!.widthRatio * 150
                                  : sizes!.width / 2.1,
                              height: sizes!.heightRatio * 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: GetGenericText(
                                  text: AppLocalizations.of(
                                    context,
                                  )!.login, //"Login",
                                  fontSize: sizes!.isPhone ? 16 : 20,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryGold500,
                                ),
                              ),
                            ),
                          ),

                          // get started button
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: sizes!.isPhone
                                  ? sizes!.widthRatio * 150
                                  : sizes!.width / 2.1,
                              height: sizes!.isPhone
                                  ? sizes!.heightRatio * 50
                                  : sizes!.heightRatio * 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment(1.00, 0.01),
                                  end: Alignment(-1, -0.01),
                                  colors: [
                                    Color(0xFFBBA473),
                                    Color(0xFF675A3D),
                                  ],
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isRtl)
                                    SvgPicture.asset(
                                      'assets/svg/forward_arrow.svg',
                                      height: sizes!.isPhone
                                          ? sizes!.heightRatio * 20
                                          : sizes!.heightRatio * 24,
                                      width: sizes!.isPhone
                                          ? sizes!.widthRatio * 20
                                          : sizes!.widthRatio * 24,
                                    ),
                                  GetGenericText(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.getStarted,
                                    //"Get Started",
                                    fontSize: sizes!.isPhone ? 16 : 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  ConstPadding.sizeBoxWithWidth(width: 6),
                                  if (!isRtl)
                                    SvgPicture.asset(
                                      'assets/svg/forward_arrow.svg',
                                      height: sizes!.heightRatio * 20,
                                      width: sizes!.widthRatio * 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // GestureDetector(
                      //   onTap: () {
                      //     Toasts.getWarningToast(text: "Try it later");
                      //   },
                      //   child: GetGenericText(
                      //     text: "Register for a Demo Account",
                      //     fontSize:
                      //         sizes!.responsiveFont(phoneVal: 14, tabletVal: 18),
                      //     //14,
                      //     fontWeight: FontWeight.w700,
                      //     color: AppColors.primaryGold500,
                      //     isUnderline: true,
                      //   ),
                      // ),
                      // ConstPadding.sizeBoxWithHeight(height: 24),
                    ],
                  ).get20HorizontalPadding(),
          ),
        ),
      ),
    );
  }
}
