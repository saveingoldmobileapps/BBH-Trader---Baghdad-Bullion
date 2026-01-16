import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
          SvgPicture.asset("assets/svg/EmptyState.svg"),
          ConstPadding.sizeBoxWithHeight(height: 12),
          GetGenericText(
            text: title,
            fontSize: sizes!.responsiveFont(
              phoneVal: 18,
              tabletVal: 20,
            ),
            fontWeight: FontWeight.bold,
            color: AppColors.whiteColor,
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
            color: AppColors.whiteColor,
          ),
        ],
      ),
    );
  }
}
