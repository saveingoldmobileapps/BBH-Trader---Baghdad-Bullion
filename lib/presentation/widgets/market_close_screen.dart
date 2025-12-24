import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';

class MarketCloseScreen extends StatelessWidget {
  const MarketCloseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/Layer_1.svg',
              height: 266,
              width: 129,
            ),
            ConstPadding.sizeBoxWithHeight(height: 24),
            GetGenericText(
              text: "Market Closed",
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: AppColors.whiteColor,
              textAlign: TextAlign.center,
            ),
            ConstPadding.sizeBoxWithHeight(height: 8),
            GetGenericText(
              text:
                  "The gold market is currently closed for the weekend. Trading operates Monday to Friday and will resume on Monday.",
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.grey4Color,
              lines: 4,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
