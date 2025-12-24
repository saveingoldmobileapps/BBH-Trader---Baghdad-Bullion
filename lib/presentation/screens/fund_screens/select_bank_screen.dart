import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/presentation/screens/fund_screens/bank_detail_screen.dart';

class SelectBankScreen extends ConsumerStatefulWidget {
  const SelectBankScreen({super.key});

  @override
  ConsumerState createState() => _SelectBankScreenState();
}

class _SelectBankScreenState extends ConsumerState<SelectBankScreen> {
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: GetGenericText(
          text: "SaveInGold Bank Accounts",
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
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
              ConstPadding.sizeBoxWithHeight(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BankDetailScreen(),
                    ),
                  );
                },
                child: Container(
                  width: sizes!.isPhone
                      ? sizes!.widthRatio * 361
                      : sizes!.width,
                  // height: sizes!.heightRatio * 60,
                  padding: const EdgeInsets.all(12),
                  decoration: ShapeDecoration(
                    color: Color(0xFF333333),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        "assets/svg/bank_icon.svg",
                        height: sizes!.heightRatio * 24,
                        width: sizes!.widthRatio * 24,
                      ),
                      ConstPadding.sizeBoxWithWidth(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GetGenericText(
                            text: "Zand Bank",
                            fontSize: sizes!.isPhone ? 14 : 20,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey6Color,
                          ),
                          GetGenericText(
                            text: "Dubai",
                            fontSize: sizes!.isPhone ? 11 : 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.grey3Color,
                          ),
                        ],
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
