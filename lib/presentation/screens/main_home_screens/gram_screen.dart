import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/gram_screens/gram_deal_detail_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/gram_provider/gram_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/shimmers/shimmer_loader.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

import '../../sharedProviders/providers/sseGoldPriceProvider/sse_gold_price_provider.dart';
import '../../widgets/no_data_widget.dart';
import '../notification_screens/notification_screen.dart';

class GramScreen extends ConsumerStatefulWidget {
  const GramScreen({super.key});

  @override
  ConsumerState createState() => _GramScreenState();
}

class _GramScreenState extends ConsumerState<GramScreen> {
  // open or close drawer
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void fetchData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gramProvider.notifier).getUserGramBalance();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(goldPriceProvider);
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);

    ///provider
    final gramStateWatchProvider = ref.watch(gramProvider);
    final goldPriceState = ref.watch(goldPriceProvider);
    //final gramStateReadProvider = ref.read(gramProvider.notifier);

    return Scaffold(
      key: _scaffoldKey,
      drawer: GetDrawerBar(
        onTap: () => _scaffoldKey.currentState!.openEndDrawer(),
      ),
      appBar: AppBar(
        centerTitle: false,
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
          text: AppLocalizations.of(
            context,
          )!.gramsBalance_title, //"Grams Balance",
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
          child: RefreshIndicator(
            backgroundColor: AppColors.primaryGold500,
            color: AppColors.whiteColor,
            onRefresh: () async {
              await ref.read(gramProvider.notifier).getUserGramBalance();
            },
            child: Column(
              children: [
                ///  PNL Summary Section
                Builder(
                  builder: (_) {
                    double totalPnl = 0;

                    if (gramStateWatchProvider.gramApiResponseModel.payload !=
                            null &&
                        gramStateWatchProvider
                            .gramApiResponseModel
                            .payload!
                            .isNotEmpty &&
                        goldPriceState.hasValue) {
                      for (var item
                          in gramStateWatchProvider
                              .gramApiResponseModel
                              .payload!) {
                        final tradeType = item.tradeType?.toLowerCase() ?? "";
                        final tradeStatus =
                            item.tradeStatus?.toLowerCase() ?? "";
                        final buyAtPriceStatus = item.buyAtPriceStatus ?? false;

                        // ======================================================
                        // SKIP PNL IF:
                        // Buy + Pending + buyAtPriceStatus == true
                        // ======================================================
                        if (tradeType == "buy" &&
                            tradeStatus == "pending" &&
                            buyAtPriceStatus == true) {
                          continue;
                        }

                        // EXISTING SKIP FOR ANY PENDING STATUS
                        // if (tradeStatus == "pending") {
                        //   continue;
                        // }

                        final pnl = CommonService.calculateLossOrProfit(
                          buyingPrice: item.buyingPrice ?? 0,
                          livePrice:
                              goldPriceState.value!.oneGramSellingPriceInAED,
                          tradeMetalFactor: item.tradeMetal ?? 0,
                        );
                        totalPnl += pnl;
                      }

                      Icon pnlIcon;
                      Color pnlColor;
                      String pnlText;

                      if (totalPnl > 0) {
                        pnlIcon = const Icon(
                          Icons.arrow_upward,
                          color: Colors.green,
                          size: 20,
                        );
                        pnlColor = Colors.green;
                        pnlText = AppLocalizations.of(context)!.gram_total;
                      } else if (totalPnl < 0) {
                        pnlIcon = const Icon(
                          Icons.arrow_downward,
                          color: Colors.red,
                          size: 20,
                        );
                        pnlColor = Colors.red;
                        pnlText = AppLocalizations.of(context)!.gram_total;
                      } else {
                        pnlIcon = const Icon(
                          Icons.horizontal_rule,
                          color: Colors.grey,
                          size: 20,
                        );
                        pnlColor = Colors.grey;
                        pnlText = AppLocalizations.of(context)!.gram_no_change;
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.greyScale900,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            pnlIcon,
                            const SizedBox(width: 8),
                            Text(
                              "$pnlText (${totalPnl.toStringAsFixed(2)} ${AppLocalizations.of(context)!.aed_currency})",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: pnlColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),

                ///  PNL Summary Section
                // Builder(
                //   builder: (_) {
                //     double totalPnl = 0;

                //     if (gramStateWatchProvider.gramApiResponseModel.payload !=
                //             null &&
                //         gramStateWatchProvider
                //             .gramApiResponseModel.payload!.isNotEmpty &&
                //         goldPriceState.hasValue) {
                //       for (var item in gramStateWatchProvider
                //           .gramApiResponseModel.payload!) {
                //         final pnl = CommonService.calculateLossOrProfit(
                //           buyingPrice: item.buyingPrice ?? 0,
                //           livePrice:
                //               goldPriceState.value!.oneGramSellingPriceInAED,
                //           tradeMetalFactor: item.tradeMetal ?? 0,
                //         );
                //         totalPnl += pnl;
                //       }

                //       Icon pnlIcon;
                //       Color pnlColor;
                //       String pnlText;

                //       if (totalPnl > 0) {
                //         pnlIcon = const Icon(
                //           Icons.arrow_upward,
                //           color: Colors.green,
                //           size: 20,
                //         );
                //         pnlColor = Colors.green;
                //         pnlText = AppLocalizations.of(context)!
                //             .gram_total; //"Total";//"You are in Profit";
                //       } else if (totalPnl < 0) {
                //         pnlIcon = const Icon(
                //           Icons.arrow_downward,
                //           color: Colors.red,
                //           size: 20,
                //         );
                //         pnlColor = Colors.red;
                //         pnlText = AppLocalizations.of(context)!
                //             .gram_total; //"Total";//"You are in Loss";
                //       } else {
                //         pnlIcon = const Icon(
                //           Icons.horizontal_rule,
                //           color: Colors.grey,
                //           size: 20,
                //         );
                //         pnlColor = Colors.grey;
                //         pnlText = AppLocalizations.of(context)!
                //             .gram_no_change; //"No Change";
                //       }

                //       return Container(
                //         padding: const EdgeInsets.symmetric(
                //           vertical: 12,
                //           horizontal: 16,
                //         ),
                //         margin: const EdgeInsets.only(bottom: 12),
                //         decoration: BoxDecoration(
                //           color: AppColors.greyScale900,
                //           borderRadius: BorderRadius.circular(8),
                //         ),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             pnlIcon,
                //             const SizedBox(width: 8),
                //             Text(
                //               "$pnlText (${totalPnl.toStringAsFixed(2)} ${AppLocalizations.of(context)!.aed_currency})",
                //               // "$pnlText (${totalPnl.toStringAsFixed(2)} AED)",
                //               style: TextStyle(
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.bold,
                //                 color: pnlColor,
                //               ),
                //             ),
                //           ],
                //         ),
                //       );
                //     }
                //     return const SizedBox.shrink();
                //   },
                // ),
                Expanded(
                  child:
                      gramStateWatchProvider.loadingState ==
                          LoadingState.loading
                      ? Center(
                          child: ShimmerLoader(
                            loop: sizes!.isPhone ? 4 : 6,
                          ),
                        )
                      : gramStateWatchProvider.loadingState ==
                            LoadingState.error
                      ? Center(
                          child: NoDataWidget(
                            title: AppLocalizations.of(
                              context,
                            )!.empty_no_data, //"No Data To Show",
                            description: AppLocalizations.of(
                              context,
                            )!.empty_no_gram_balance, //"No gram balance found",
                          ),
                        )
                      : (gramStateWatchProvider
                            .gramApiResponseModel
                            .payload!
                            .isEmpty)
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              NoDataWidget(
                                title: AppLocalizations.of(
                                  context,
                                )!.empty_no_data, //"No Data To Show",
                                description: AppLocalizations.of(
                                  context,
                                )!.empty_no_gram_balance, //"No gram balance found",
                              ),
                            ],
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final appSizes = AppSizes()
                              ..initializeSize(context);
                            final isTablet = !appSizes.isPhone;

                            return GridView.builder(
                              itemCount:
                                  gramStateWatchProvider
                                      .gramApiResponseModel
                                      .payload
                                      ?.length ??
                                  0,
                              padding: const EdgeInsets.all(8),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isTablet ? 2 : 1,
                                    crossAxisSpacing: 7,
                                    mainAxisSpacing: 7,
                                    childAspectRatio: isTablet ? 2 : 1.8,
                                  ),
                              itemBuilder: (context, index) {
                                return Directionality.of(context) ==
                                        TextDirection.rtl
                                    ? GramBalanceCard(
                                        gramList: gramStateWatchProvider
                                            .gramApiResponseModel
                                            .payload![index],
                                        rtl:
                                            Directionality.of(context) ==
                                            TextDirection.rtl,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  GramDealDetailScreen(
                                                    gramData:
                                                        gramStateWatchProvider
                                                            .gramApiResponseModel
                                                            .payload![index],
                                                  ),
                                            ),
                                          );
                                        },
                                      ).get6VerticalPadding()
                                    : GramBalanceCard(
                                        gramList: gramStateWatchProvider
                                            .gramApiResponseModel
                                            .payload![index],
                                        rtl:
                                            Directionality.of(context) ==
                                            TextDirection.rtl,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  GramDealDetailScreen(
                                                    gramData:
                                                        gramStateWatchProvider
                                                            .gramApiResponseModel
                                                            .payload![index],
                                                  ),
                                            ),
                                          );
                                        },
                                      ).get6VerticalPadding();
                              },
                            );
                          },
                        ),
                ),
              ],
            ).get16HorizontalPadding(),
          ),
        ),
      ),
    );
  }
}
