import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/gift_provider/gift_fund_provider.dart';

import '../../widgets/shimmers/shimmer_loader.dart';
import '../main_home_screens/main_home_screen.dart';

class TransactionFailedScreen extends ConsumerStatefulWidget {
  const TransactionFailedScreen({
    super.key,
  });

  @override
  ConsumerState createState() => _TransactionFailedScreenState();
}

class _TransactionFailedScreenState
    extends ConsumerState<TransactionFailedScreen> {
  @override
  void initState() {
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
    sizes!.refreshSize(context);

    final giftState = ref.watch(giftProvider);

    return WillPopScope(
      onWillPop: () async {
        // Navigate to home screen and prevent default back behavior
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainHomeScreen()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        body: Container(
          height: sizes!.height,
          width: sizes!.width,
          decoration: const BoxDecoration(
            color: AppColors.greyScale1000,
          ),
          child: giftState.loadingState == LoadingState.loading
              ? ShimmerLoader(
                  loop: 5,
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: sizes!.heightRatio * 16,
                          horizontal: sizes!.widthRatio * 16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              "assets/svg/failed_icon.svg",
                              height: sizes!.heightRatio * 48,
                              width: sizes!.widthRatio * 48,
                            ),
                            ConstPadding.sizeBoxWithHeight(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GetGenericText(
                                text: "Transaction unsuccessful",
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey6Color,
                                lines: 2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            ConstPadding.sizeBoxWithHeight(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GetGenericText(
                                text:
                                    "Your direct transfer of AED10,000.00 failed due to technical issues. Click on the button below to try again or contact customer support.",
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                color: AppColors.grey4Color,
                                lines: 6,
                                textAlign: TextAlign.start,
                              ),
                            ),
                            ConstPadding.sizeBoxWithHeight(height: 20),
                            GestureDetector(
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MainHomeScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: sizes!.isPhone
                                    ? sizes!.widthRatio * 360
                                    : sizes!.width,
                                height: sizes!.responsiveLandscapeHeight(
                                  phoneVal: 50,
                                  tabletVal: 60,
                                  tabletLandscapeVal: 70,
                                  isLandscape: sizes!.isLandscape(),
                                ),
                                decoration: BoxDecoration(
                                  //color: AppColors.primaryGold500,
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                    begin: Alignment(1.00, 0.01),
                                    end: Alignment(-1, -0.01),
                                    colors: [
                                      Color(0xFF675A3D),
                                      Color(0xFFBBA473),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GetGenericText(
                                        text: "Try Again",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            ConstPadding.sizeBoxWithHeight(height: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TransactionFailedScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: sizes!.isPhone
                                    ? sizes!.widthRatio * 360
                                    : sizes!.width,
                                height: sizes!.responsiveLandscapeHeight(
                                  phoneVal: 50,
                                  tabletVal: 60,
                                  tabletLandscapeVal: 70,
                                  isLandscape: sizes!.isLandscape(),
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0x33BBA473),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    width: 1.50,
                                    color: Color(0xFFBBA473),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/svg/support_icon.svg",
                                      color: Colors.white,
                                      height:
                                          sizes!.heightRatio *
                                          (sizes!.isPhone
                                              ? 22
                                              : (sizes!.isLandscape()
                                                    ? 32
                                                    : 20)),
                                      width:
                                          sizes!.widthRatio *
                                          (sizes!.isPhone
                                              ? 22
                                              : (sizes!.isLandscape()
                                                    ? 32
                                                    : 20)),
                                    ),
                                    ConstPadding.sizeBoxWithWidth(width: 10),
                                    GetGenericText(
                                      text: "Customer Support",
                                      fontSize: sizes!.responsiveFont(
                                        phoneVal: 16,
                                        tabletVal: 18,
                                      ), //16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).get16HorizontalPadding(),
        ),
      ),
    );
  }
}
