import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

import '../../../../core/core_export.dart';
import 'bank_add_fund_screen.dart';
import 'bank_new_link_screen.dart';

class ReturningUserScreen extends ConsumerStatefulWidget {
  const ReturningUserScreen({super.key});

  @override
  ConsumerState createState() => _ReturningUserScreenState();
}

class _ReturningUserScreenState extends ConsumerState<ReturningUserScreen> {
  bool isDefault = true;

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
      ),
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        decoration: const BoxDecoration(
          color: AppColors.greyScale1000,
        ),
        child: SafeArea(
          child: Column(
            children: [
              GetGenericText(
                text: "Easy Bank Transfer",
                fontSize: sizes!.isPhone ? 28 : 30,
                fontWeight: FontWeight.w400,
                color: AppColors.grey6Color,
              ).getAlign(),
              GetGenericText(
                text:
                    "Save In Gold-FZCO uses Lean to connect to your bank account.",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 16,
                  tabletVal: 18,
                ),
                fontWeight: FontWeight.w400,
                color: AppColors.grey3Color,
              ),
              ConstPadding.sizeBoxWithHeight(height: 16),

              /// Default Bank
              defaultBankCard(),
              ConstPadding.sizeBoxWithHeight(height: 16),

              /// add new account
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BankNewLinkScreen(),
                    ),
                  );
                },
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/svg/round_plus.svg"),
                      ConstPadding.sizeBoxWithWidth(width: 4),
                      GetGenericText(
                        text: "Add new account",
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey4Color,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),
              LoaderArrowButton(
                title: "Continue",
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BankAddFundScreen(),
                    ),
                  );
                },
              ),
              const Spacer(),
            ],
          ).get16HorizontalPadding(),
        ),
      ),
    );
  }

  Widget defaultBankCard() {
    return Container(
      width: sizes!.width,
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 2,
            color: isDefault
                ? const Color(0xFFBBA473)
                : const Color(0xFF79747E),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: sizes!.heightRatio * 34,
            width: sizes!.widthRatio * 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.grey3Color,
            ),
          ),
          ConstPadding.sizeBoxWithWidth(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GetGenericText(
                      text: "Mashreq Bank",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.whiteColor,
                    ),
                    const Spacer(),
                    GetGenericText(
                      text: "Default",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.whiteColor,
                    ),
                    ConstPadding.sizeBoxWithWidth(width: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isDefault = !isDefault;
                        });
                      },
                      child: Container(
                        width: sizes!.widthRatio * 16,
                        height: sizes!.heightRatio * 16,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: isDefault ? AppColors.primaryGold500 : null,
                          border: Border.all(
                            color: isDefault
                                ? AppColors.primaryGold500
                                : AppColors.grey3Color,
                            width: 1.5,
                          ),
                        ),
                        child: Visibility(
                          visible: isDefault,
                          child: Icon(
                            Icons.check,
                            color: AppColors.greyScale900,
                            size: sizes!.widthRatio * 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                GetGenericText(
                  text: "****3421",
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey3Color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
