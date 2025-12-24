import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/gift_provider/gift_fund_provider.dart';

import '../../widgets/shimmers/shimmer_loader.dart';
import '../main_home_screens/main_home_screen.dart';

class TransactionSuccessScreen extends ConsumerStatefulWidget {
  const TransactionSuccessScreen({
    super.key,
  });

  @override
  ConsumerState createState() => _EsouqCartScreenState();
}

class _EsouqCartScreenState extends ConsumerState<TransactionSuccessScreen> {
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
    /// Refresh sizes on orientation change
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
          child:  giftState.loadingState == LoadingState.loading
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
                              "assets/svg/success_tick_icon.svg",
                              height: sizes!.heightRatio * 48,
                              width: sizes!.widthRatio * 48,
                            ),
                            ConstPadding.sizeBoxWithHeight(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GetGenericText(
                                text: "Success!",
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
                                    "You’ve successfully uploaded your transaction receipt. Funds will transferred to your account within 24 to 48 hours.",
                                fontSize: 16,
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
                                height: sizes!.fontRatio * 48,
                                // width: sizes!.widthRatio * 300,
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
                                        text: "DONE",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
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
