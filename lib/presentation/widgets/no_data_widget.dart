import 'package:flutter/material.dart';
import 'package:saveingold_fzco/core/res_sizes/res.dart';

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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: sizes!.heightRatio * 50,
            width: sizes!.widthRatio * 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.primaryGold500,
            ),
            child: Icon(
              Icons.cancel_outlined,
              color: AppColors.whiteColor,
              size: 32,
            ),
          ),
          ConstPadding.sizeBoxWithHeight(height: 12),
          GetGenericText(
            text: title,
            fontSize: sizes!.responsiveFont(
              phoneVal: 14,
              tabletVal: 16,
            ),
            fontWeight: FontWeight.bold,
            color: AppColors.grey6Color,
          ),
          ConstPadding.sizeBoxWithHeight(height: 10),
          GetGenericText(
            text: description,
            textAlign: TextAlign.center,
            fontSize: sizes!.responsiveFont(
              phoneVal: 14,
              tabletVal: 16,
            ),
            fontWeight: FontWeight.normal,
            color: AppColors.grey2Color,
          ),
        ],
      ),
    );
  }
}
