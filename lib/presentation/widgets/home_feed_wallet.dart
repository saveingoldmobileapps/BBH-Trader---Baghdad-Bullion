import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/data_sources/local_database/local_database.dart';
import 'package:saveingold_fzco/data/models/home_models/GetHomeFeedResponse.dart';
import 'package:saveingold_fzco/presentation/screens/setting_screens/setting_screen.dart';
import 'package:saveingold_fzco/presentation/widgets/pop_up_widget.dart';

import '../../l10n/app_localizations.dart';

class HomeFeedWallet extends StatelessWidget {
  final bool isHiddenBalance;
  final WalletExists walletExists;
  final VoidCallback onBalancePress;
  final VoidCallback onDepositPress;

  const HomeFeedWallet({
    super.key,
    required this.isHiddenBalance,
    required this.walletExists,
    required this.onBalancePress,
    required this.onDepositPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sizes!.isPhone ? sizes!.widthRatio * 360 : sizes!.width,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Color(0xFF232323),
        image: DecorationImage(
          image: AssetImage(
            "assets/png/account_card_bg.png",
          ),
          fit: BoxFit.cover,
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Color(0xFFBBA473),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetGenericText(
                text: AppLocalizations.of(
                  context,
                )!.my_account,
                fontSize: sizes!.responsiveFont(
                  phoneVal: 16,
                  tabletVal: 20,
                ),
                //16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                isInter: true,
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onBalancePress,
                  borderRadius: BorderRadius.circular(8),
                  splashColor: Colors.white.withValues(alpha: 0.2),
                  highlightColor: Colors.white.withValues(alpha: 0.1),
                  child: Ink(
                    width: sizes!.responsiveWidth(
                      phoneVal: 100,
                      tabletVal: 120,
                    ),
                    height: sizes!.responsiveLandscapeHeight(
                      phoneVal: 24,
                      tabletVal: 34,
                      tabletLandscapeVal: 42,
                      isLandscape: sizes!.isLandscape(),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: GetGenericText(
                        text: isHiddenBalance
                            ? AppLocalizations.of(
                                context,
                              )!.show_balance
                            : AppLocalizations.of(
                                context,
                              )!.hide_balance,
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 12,
                          tabletVal: 14,
                        ),
                        fontWeight: FontWeight.w400,
                        color: AppColors.greyScale900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ConstPadding.sizeBoxWithHeight(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetGenericText(
                text: isHiddenBalance
                    ? "*****"
                    : walletExists.metalBalance!.toStringAsFixed(2),
                fontSize: sizes!.responsiveFont(
                  phoneVal: 24,
                  tabletVal: 28,
                ),
                fontWeight: FontWeight.w600,
                color: Colors.white,
                isInter: true,
              ),
              GetGenericText(
                text: isHiddenBalance
                    ? "*****"
                    : walletExists.moneyBalance != null
                    ? walletExists.moneyBalance!.toStringAsFixed(2)
                    : "",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 24,
                  tabletVal: 28,
                ),
                fontWeight: FontWeight.w600,
                color: Colors.white,
                isInter: true,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetGenericText(
                text:
                    "${AppLocalizations.of(
                      context,
                    )!.total_gold} ( ${CommonService.convertWeightUnit(
                      grams: double.parse(
                        "${walletExists.metalBalance}",
                      ),
                    )} )",
                fontSize: sizes!.responsiveFont(phoneVal: 12, tabletVal: 14),
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              GetGenericText(
                text: AppLocalizations.of(
                  context,
                )!.total_funds_aed,
                fontSize: sizes!.responsiveFont(phoneVal: 12, tabletVal: 14),
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ],
          ),
          ConstPadding.sizeBoxWithHeight(height: 20),

          walletExists.frozenMetalBalance != null &&
                  walletExists.frozenMetalBalance.toString().isNotEmpty &&
                  double.tryParse(walletExists.frozenMetalBalance.toString()) !=
                      null &&
                  double.parse(walletExists.frozenMetalBalance.toString()) > 0
              ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Hold (Gram) text
                        GetGenericText(
                          text: AppLocalizations.of(
                            context,
                          )!.gold,
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 12,
                            tabletVal: 14,
                          ),
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                        Expanded(
                          child: Center(
                            child: GetGenericText(
                              text: AppLocalizations.of(
                                context,
                              )!.money,
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 12,
                                tabletVal: 14,
                              ),
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Container(
                        //   width: sizes!.responsiveWidth(
                        //     phoneVal: 100,
                        //     tabletVal: 100,
                        //   ),
                        // ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Frozen balance
                        GetGenericText(
                          text: walletExists.frozenMetalBalance!
                              .toStringAsFixed(2),
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 12,
                            tabletVal: 14,
                          ),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          isInter: true,
                        ),

                        // Loan amount centered under Advance
                        Expanded(
                          child: Center(
                            child: GetGenericText(
                              text: walletExists.loanAmountBalance!
                                  .toStringAsFixed(2),
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 12,
                                tabletVal: 14,
                              ),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              isInter: true,
                            ),
                          ),
                        ),

                        // Pay Now button
                        // Material(
                        //   color: Colors.transparent,
                        //   child: Ink(
                        //     width: sizes!.responsiveWidth(
                        //       phoneVal: 80,
                        //       tabletVal: 100,
                        //     ),
                        //     height: sizes!.responsiveLandscapeHeight(
                        //       phoneVal: 24,
                        //       tabletVal: 34,
                        //       tabletLandscapeVal: 42,
                        //       isLandscape: sizes!.isLandscape(),
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: const Color.fromRGBO(255, 255, 255, 0.2),
                        //       borderRadius: BorderRadius.circular(8),
                        //     ),
                        //     child: InkWell(
                        //       onTap: () {
                        //         Toasts.getErrorToast(
                        //           gravity: ToastGravity.TOP,
                        //           text: 'Wait... In Progress',
                        //           duration: const Duration(seconds: 2),
                        //         );
                        //       },
                        //       borderRadius: BorderRadius.circular(8),
                        //       splashColor: Colors.white.withOpacity(0.2),
                        //       highlightColor: Colors.white.withOpacity(0.1),
                        //       child: Center(
                        //         child: GetGenericText(
                        //           text: "Pay Now",
                        //           fontSize: sizes!.responsiveFont(
                        //             phoneVal: 12,
                        //             tabletVal: 14,
                        //           ),
                        //           fontWeight: FontWeight.w400,
                        //           color: AppColors.whiteColor,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                )
              : const SizedBox.shrink(),
          ConstPadding.sizeBoxWithHeight(height: 20),

          //add deposit
          Material(
            color: Colors.transparent,
            child: InkWell(
              //onTap: onDepositPress
              onTap: () async {
                final isDemo =
                    await LocalDatabase.instance.getIsDemo() ?? false;

                if (isDemo) {
                  if (!context.mounted) return;
                  await genericPopUpWidget(
                    isLoadingState: false,
                    context: context,
                    heading: AppLocalizations.of(
                      context,
                    )!.upgrade_real_account_title,
                    subtitle: AppLocalizations.of(
                      context,
                    )!.upgrade_feature_message,
                    noButtonTitle: AppLocalizations.of(
                      context,
                    )!.not_now,
                    yesButtonTitle: AppLocalizations.of(
                      context,
                    )!.upgrade_now,
                    onNoPress: () async => Navigator.pop(context),
                    onYesPress: () async {
                      Navigator.pop(context);
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingScreen(),
                        ),
                      );
                    },
                  );
                } else {
                  onDepositPress(); // No null-check if it's non-nullable
                }
              },
              borderRadius: BorderRadius.circular(10),
              splashColor: Colors.white.withValues(alpha: 0.2),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              child: Ink(
                width: sizes!.isPhone ? sizes!.widthRatio * 330 : sizes!.width,
                height: sizes!.responsiveLandscapeHeight(
                  phoneVal: 40,
                  tabletVal: 56,
                  tabletLandscapeVal: 64,
                  isLandscape: sizes!.isLandscape(),
                ),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0x33BBA473),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 0.5,
                    color: const Color(0xFFBBA473),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/svg/add_circle.svg",
                      height: sizes!.responsiveHeight(
                        phoneVal: 20,
                        tabletVal: 24,
                      ),
                      width: sizes!.responsiveWidth(
                        phoneVal: 20,
                        tabletVal: 24,
                      ),
                    ),
                    ConstPadding.sizeBoxWithWidth(width: 10),
                    GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.deposit,
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 18,
                      ),
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
