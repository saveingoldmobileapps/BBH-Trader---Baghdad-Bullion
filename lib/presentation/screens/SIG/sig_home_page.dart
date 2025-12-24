import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/language_provider.dart';

import '../notification_screens/notification_screen.dart';
import 'deposit_funds/deposit_payment_method.dart';

class SigHomePage extends ConsumerStatefulWidget {
  const SigHomePage({super.key});

  @override
  ConsumerState createState() => _SigHomePageState();
}

class _SigHomePageState extends ConsumerState<SigHomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState

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

  @override
  Widget build(BuildContext context) {
    //final languageState = ref.watch(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);
    // Determine the direction of the arrow based on the current locale
    bool isRtl = languageNotifier.isRtl();
    sizes!.refreshSize(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.greyScale1000,
        leading: GestureDetector(
          onTap: () => _scaffoldKey.currentState!.openDrawer(),
          child: Container(
            color: Colors.transparent,
            height: sizes!.heightRatio * 24,
            width: sizes!.widthRatio * 24,
            child: Center(
              child: SvgPicture.asset(
                "assets/svg/menu_icon.svg",
              ),
            ),
          ),
        ),
        titleSpacing: 0,
        title: GetGenericText(
          text: "SIG Card",
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        actions: [
          Directionality.of(context) == TextDirection.rtl?
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
              child: Container(
                color: Colors.transparent,
                child: SvgPicture.asset(
                  "assets/svg/notify_icon.svg",
                  height: sizes!.responsiveHeight(
                    phoneVal: 24,
                    tabletVal: 32,
                  ),
                  width: sizes!.responsiveWidth(
                    phoneVal: 24,
                    tabletVal: 32,
                  ),
                ),
              ),
            ),
          )
          : Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
              child: Container(
                color: Colors.transparent,
                child: SvgPicture.asset(
                  "assets/svg/notify_icon.svg",
                  height: sizes!.responsiveHeight(
                    phoneVal: 24,
                    tabletVal: 32,
                  ),
                  width: sizes!.responsiveWidth(
                    phoneVal: 24,
                    tabletVal: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
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
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title: SIG CARD
            Text(
              "SIG\n",
              textAlign: TextAlign.start,
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: sizes!.isPhone
                    ? sizes!.fontRatio * 140
                    : sizes!.fontRatio * 158,
                fontFamily: GoogleFonts.roboto().fontFamily,
                fontWeight: FontWeight.w400,
                height: 0.3,
              ),
            ),
            Text(
              "CARD",
              textAlign: TextAlign.start,
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: sizes!.isPhone
                    ? sizes!.fontRatio * 130
                    : sizes!.fontRatio * 158,
                fontFamily: GoogleFonts.roboto().fontFamily,
                fontWeight: FontWeight.normal,
                height: 0.9,
              ),
            ),
            const SizedBox(height: 16), // Adjust spacing

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GetGenericText(
                text: AppLocalizations.of(context)!.gs_subtitle,
                fontSize: sizes!.isPhone ? 16 : 22,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ).getAlign(),
            ),

            const SizedBox(height: 50),

            // "Get Started" Button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SigSelectPaymentMethod(),
                  ),
                );
              },
              child: Center(
                child: Container(
                  width: sizes!.width,
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
                        text: AppLocalizations.of(context)!.getStarted,
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
            ),
          ],
        ).getHorizontalPadding(padding: 10)),
      ),
    );
  }
}
