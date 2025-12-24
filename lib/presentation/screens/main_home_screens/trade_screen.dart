import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

import '../../../l10n/app_localizations.dart';
import '../notification_screens/notification_screen.dart';
import '../trade_screens/buy_gold_screen.dart';
import '../trade_screens/sell_gold_screen.dart';

enum TradeType {
  buy,
  sell,
}

class TradeScreen extends ConsumerStatefulWidget {
  const TradeScreen({super.key});

  @override
  ConsumerState createState() => _TradeScreenState();
}

class _TradeScreenState extends ConsumerState<TradeScreen> {
  // open or close drawer
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var tradeType = TradeType.buy;

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
    /// Refresh sizes on orientation change
    sizes!.refreshSize(context);
    // Get current weekday
    //final int today = DateTime.now().weekday; // Monday = 1, Sunday = 7

    return Scaffold(
      key: _scaffoldKey,
      drawer: GetDrawerBar(
        onTap: () => _scaffoldKey.currentState!.openEndDrawer(),
      ),
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
          text: AppLocalizations.of(context)!.invest,
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
        ],),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: sizes!.height,
          width: sizes!.width,
          decoration: const BoxDecoration(
            color: AppColors.greyScale1000,
          ),
          child: SafeArea(
            child:
                // (today == DateTime.saturday || today == DateTime.sunday)
                //     ? MarketCloseScreen()
                //     :
                SingleChildScrollView(
                  child: Column(
                    children: [
                      /// Trade Type Tabs (Buy/Sell)
                      Container(
                        height: sizes!.responsiveLandscapeHeight(
                          phoneVal: 44,
                          tabletVal: 44,
                          tabletLandscapeVal: 64,
                          isLandscape: sizes!.isLandscape(),
                        ),
                        width: sizes!.isPhone
                            ? sizes!.widthRatio * 360
                            : sizes!.width,
                        decoration: BoxDecoration(
                          color: const Color(0xFF333333),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: sizes!.widthRatio * 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Buy tab
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      tradeType = TradeType.buy;
                                    });
                                  },
                                  child: Container(
                                    height: sizes!.responsiveLandscapeHeight(
                                      phoneVal: 34,
                                      tabletVal: 44,
                                      tabletLandscapeVal: 54,
                                      isLandscape: sizes!.isLandscape(),
                                    ),
                                    decoration: tradeType == TradeType.buy
                                        ? BoxDecoration(
                                            color: AppColors.primaryGold500,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          )
                                        : null,
                                    child: Center(
                                      child: GetGenericText(
                                        text: AppLocalizations.of(
                                          context,
                                        )!.gold,
                                        fontSize: sizes!.isPhone ? 18 : 22,
                                        fontWeight: tradeType == TradeType.buy
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                        color: tradeType == TradeType.buy
                                            ? AppColors.greyScale1000
                                            : AppColors.grey3Color,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Sell tab
                              // Expanded(
                              //   child: GestureDetector(
                              //     behavior: HitTestBehavior.opaque,
                              //     onTap: () {
                              //       setState(() {
                              //         tradeType = TradeType.sell;
                              //       });
                              //     },
                              //     child: Container(
                              //       height: sizes!.responsiveLandscapeHeight(
                              //         phoneVal: 34,
                              //         tabletVal: 44,
                              //         tabletLandscapeVal: 54,
                              //         isLandscape: sizes!.isLandscape(),
                              //       ),
                              //       decoration: tradeType == TradeType.sell
                              //           ? BoxDecoration(
                              //               color: AppColors.primaryGold500,
                              //               borderRadius:
                              //                   BorderRadius.circular(4),
                              //             )
                              //           : null,
                              //       child: Center(
                              //         child: GetGenericText(
                              //           text: "Sell Gold",
                              //           fontSize: sizes!.isPhone ? 18 : 22,
                              //           fontWeight:
                              //               tradeType == TradeType.sell
                              //               ? FontWeight.w700
                              //               : FontWeight.w400,
                              //           color: tradeType == TradeType.sell
                              //               ? AppColors.greyScale1000
                              //               : AppColors.grey3Color,
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      ConstPadding.sizeBoxWithHeight(height: 24),
                      if (tradeType == TradeType.buy) const BuyGoldScreen(),
                      if (tradeType == TradeType.sell) const SellGoldScreen(),
                    ],
                  ).get16HorizontalPadding(),
                ),
          ),
        ),
      ),
    );
  }
}
