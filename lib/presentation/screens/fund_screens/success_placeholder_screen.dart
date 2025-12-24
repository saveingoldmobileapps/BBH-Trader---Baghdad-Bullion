import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/core_export.dart';
import '../main_home_screens/main_home_screen.dart';

class SuccessPlaceholderScreen extends StatelessWidget {
  final String amount;

  const SuccessPlaceholderScreen({
    super.key,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        decoration: const BoxDecoration(
          color: AppColors.greyScale1000,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              SvgPicture.asset(
                "assets/svg/success_tick_icon.svg",
                height: sizes!.heightRatio * 100,
                width: sizes!.widthRatio * 100,
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerLeft,
                child: GetGenericText(
                  text: "Payment Successful!",
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey6Color,
                  lines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
              ConstPadding.sizeBoxWithHeight(height: 6),
              GetGenericText(
                text:
                    "Your payment of AED $amount to SaveInGold has been processed. Your funds may take up to 24 hours to reach Save In Gold-FZCO.",
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFC9C6C5),
                lines: 6,
              ).getAlign(),
              const Spacer(),
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
                          text: "Done",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ).get16HorizontalPadding(),
        ),
      ),
    );
  }
}
