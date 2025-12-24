import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/history_screens/metal_statement_screen.dart';
import 'package:saveingold_fzco/presentation/screens/history_screens/money_statement_screen.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

import '../notification_screens/notification_screen.dart';

enum HistoryType {
  metal,
  money,
}

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState createState() => _MetalScreenState();
}

class _MetalScreenState extends ConsumerState<HistoryScreen> {
  var historyType = HistoryType.metal;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    //final historyState = ref.watch(historyProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: GetDrawerBar(
        onTap: () => _scaffoldKey.currentState!.openEndDrawer(),
      ),
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
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
          text: AppLocalizations.of(context)!.history, //"History",
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        actions: [
          Directionality.of(context) == TextDirection.rtl
              ? Padding(
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
          color: AppColors.greyScale1000,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// Tabs for Metal and Money
                Container(
                  height: sizes!.responsiveLandscapeHeight(
                    phoneVal: 44,
                    tabletVal: 44,
                    tabletLandscapeVal: 64,
                    isLandscape: sizes!.isLandscape(),
                  ),
                  width:
                      sizes!.isPhone ? sizes!.widthRatio * 360 : sizes!.width,
                  decoration: BoxDecoration(
                    color: Color(0xFF333333),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: sizes!.widthRatio * 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Metal History Tab
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              debugPrint("MetalHistoryTab");
                              setState(() {
                                historyType = HistoryType.metal;
                              });
                            },
                            child: Container(
                              width: sizes!.responsiveWidth(
                                phoneVal: 150,
                                tabletVal: 380,
                              ),
                              height: sizes!.responsiveLandscapeHeight(
                                phoneVal: 34,
                                tabletVal: 44,
                                tabletLandscapeVal: 54,
                                isLandscape: sizes!.isLandscape(),
                              ),
                              decoration: historyType == HistoryType.metal
                                  ? BoxDecoration(
                                      color: AppColors.primaryGold500,
                                      borderRadius: BorderRadius.circular(4),
                                    )
                                  : null,
                              //replace this
                              child: Center(
                                child: GetGenericText(
                                  text: sizes!.isPhone
                                      ? AppLocalizations.of(context)!
                                          .metal //"Metal"
                                      : AppLocalizations.of(context)!.metal_st,
                                  fontSize: sizes!.responsiveFont(
                                    phoneVal: 18,
                                    tabletVal: 22,
                                  ),
                                  fontWeight: historyType == HistoryType.metal
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: historyType == HistoryType.metal
                                      ? AppColors.greyScale1000
                                      : AppColors.grey3Color,
                                ),
                              ),
                            ),
                          ),
                        ),

                        /// Money History Tab
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              debugPrint("MoneyHistoryTab");
                              setState(() {
                                historyType = HistoryType.money;
                              });
                            },
                            child: Container(
                              width: sizes!.responsiveWidth(
                                phoneVal: 150,
                                tabletVal: 380,
                              ),
                              height: sizes!.responsiveLandscapeHeight(
                                phoneVal: 34,
                                tabletVal: 44,
                                tabletLandscapeVal: 54,
                                isLandscape: sizes!.isLandscape(),
                              ),
                              decoration: historyType == HistoryType.money
                                  ? BoxDecoration(
                                      color: AppColors.primaryGold500,
                                      borderRadius: BorderRadius.circular(4),
                                    )
                                  : null,
                              //replace this
                              child: Center(
                                child: GetGenericText(
                                  text: sizes!.isPhone
                                      ? AppLocalizations.of(context)!
                                          .money //"Money"
                                      : AppLocalizations.of(context)!.money_st,
                                  fontSize: sizes!.isPhone ? 18 : 22,
                                  fontWeight: historyType == HistoryType.money
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: historyType == HistoryType.money
                                      ? AppColors.greyScale1000
                                      : AppColors.grey3Color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                ConstPadding.sizeBoxWithHeight(height: 12),
                if (historyType == HistoryType.metal)
                  const MetalStatementScreen(),
                if (historyType == HistoryType.money)
                  const MoneyStatementScreen(),
              ],
            ).get16HorizontalPadding(),
          ),
        ),
      ),
    );
  }
}
