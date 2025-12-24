import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/presentation/screens/main_home_screens/gram_screen.dart';
import 'package:saveingold_fzco/presentation/screens/main_home_screens/history_screen.dart';
import 'package:saveingold_fzco/presentation/screens/main_home_screens/home_screen.dart';
import 'package:saveingold_fzco/presentation/screens/main_home_screens/trade_screen.dart';

import '../../../core/connectivity_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../sharedProviders/providers/setting_provider/check_device_security.dart';
import '../SIG/sig_home_page.dart';

// ae.saveingold.saveingold-fzco

class MainHomeScreen extends ConsumerStatefulWidget {
  const MainHomeScreen({super.key});

  @override
  ConsumerState createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends ConsumerState<MainHomeScreen> {
  int _selectedIndex = 0;
  final connectivityService = ConnectivityService();

  // Function to handle tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // List of widgets for each tab's content
  final List<Widget> _pages = [
    HomeScreen(),
    TradeScreen(),
    GramScreen(),
    HistoryScreen(),
    SigHomePage(),
  ];

  @override
  void initState() {
    connectivityService.startMonitoring();
    BiometricUtils.hasFaceHardware();
    BiometricUtils.hasFingerprintHardware();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    /// Refresh sizes on orientation change
    sizes!.refreshSize(context);

    return Scaffold(
      backgroundColor: AppColors.greyScale1000,
      bottomNavigationBar: SafeArea(
        // top: false, // Set to true if you want to avoid notch overlap too
        bottom: !Platform.isIOS,
        child: Container(
          height: sizes!.responsiveLandscapeHeight(
            phoneVal: 76,
            tabletVal: 90,
            tabletLandscapeVal: 136,
            isLandscape: sizes!.isLandscape(),
          ),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.primaryGold500,
                width: 1,
              ),
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory,
            ),
            child: BottomNavigationBar(
              showSelectedLabels: true,
              // showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.greyScale1000,
              currentIndex: _selectedIndex,
              unselectedItemColor: AppColors.grey7Color,
              selectedItemColor: AppColors.primaryGold500,
              onTap: _onItemTapped,
              selectedLabelStyle: TextStyle(
                color: AppColors.primaryGold500,
                fontSize: sizes!.responsiveFont(
                  phoneVal: 12,
                  tabletVal: sizes!.isLandscape() ? 15 : 14,
                ),
                fontWeight: FontWeight.w700,
                fontFamily: GoogleFonts.roboto().fontFamily,
              ),
              unselectedLabelStyle: TextStyle(
                color: AppColors.grey7Color,
                fontSize: sizes!.responsiveFont(
                  phoneVal: 12,
                  tabletVal: sizes!.isLandscape() ? 15 : 14,
                ),
                fontWeight: FontWeight.w400,
                fontFamily: GoogleFonts.roboto().fontFamily,
              ),
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: iconButton(
                    iconString: "assets/svg/home_icon.svg",
                  ),
                  activeIcon: iconButton(
                    iconString: "assets/svg/home_active_icon.svg",
                  ),
                  label: AppLocalizations.of(context)!.home,
                ),
                BottomNavigationBarItem(
                  icon: iconButton(
                    iconString: "assets/svg/trade_icon.svg",
                  ),
                  activeIcon: iconButton(
                    iconString: "assets/svg/trade_active_icon.svg",
                  ),
                  label: AppLocalizations.of(context)!.invest,
                ),
                BottomNavigationBarItem(
                  icon: iconButton(
                    iconString: "assets/svg/gram_icon.svg",
                  ),
                  activeIcon: iconButton(
                    iconString: "assets/svg/gram_active_icon.svg",
                  ),
                  label: AppLocalizations.of(context)!.gram,
                ),
                BottomNavigationBarItem(
                  icon: iconButton(
                    iconString: "assets/svg/metal_icon.svg",
                  ),
                  activeIcon: iconButton(
                    iconString: "assets/svg/metal_active_icon.svg",
                  ),
                  label: AppLocalizations.of(context)!.history,
                ),
                // BottomNavigationBarItem(
                //   icon: iconButton(
                //     iconString: "assets/svg/card.svg",
                //   ),
                //   activeIcon: iconButton(
                //     iconString: "assets/svg/card.svg",
                //   ),
                //   label: 'SIG',
                // ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
    );
  }

  // icon button
  Widget iconButton({
    required String iconString,
  }) {
    return Container(
      color: Colors.transparent,
      child: SvgPicture.asset(
        iconString,
        height: sizes!.isLandscape()
            ? sizes!.heightRatio * 32
            : sizes!.heightRatio * 20,
        width: sizes!.isLandscape()
            ? sizes!.widthRatio * 32
            : sizes!.widthRatio * 20,
      ),
    );
  }
}
