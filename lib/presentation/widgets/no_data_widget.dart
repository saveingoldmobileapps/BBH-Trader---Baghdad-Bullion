import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:baghdad_bullion_house/core/res_sizes/res.dart';

import '../../core/theme/const_colors.dart';
import '../../core/theme/const_padding.dart';
import '../../core/theme/get_generic_text_widget.dart';

class NoDataWidget extends StatelessWidget {
  final String title;
  final String description;

  const NoDataWidget({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: sizes!.widthRatio * 24,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Icon
            SvgPicture.asset(
              "assets/svg/EmptyState.svg",
              height: sizes!.heightRatio * 120,
            ),

            ConstPadding.sizeBoxWithHeight(height: 20),

            /// Title
            GetGenericText(
              text: title,
              textAlign: TextAlign.center,
              fontSize: sizes!.responsiveFont(
                phoneVal: 20,
                tabletVal: 22,
              ),
              fontWeight: FontWeight.w600,
              color: AppColors.whiteColor,
            ),

            ConstPadding.sizeBoxWithHeight(height: 12),

            /// Description
            GetGenericText(
              text: description,
              textAlign: TextAlign.center,
              fontSize: sizes!.responsiveFont(
                phoneVal: 14,
                tabletVal: 16,
              ),
              fontWeight: FontWeight.w400,
              color: AppColors.whiteColor.withOpacity(0.7), // 👈 softer text
              lines: 3,
            ),
          ],
        ),
      ),
    );
  }
}