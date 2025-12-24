import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';

class BuildSettingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconString;
  final bool isSecondIcon;
  final VoidCallback onTap;

  const BuildSettingCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconString,
    required this.isSecondIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              iconString,
              height: sizes!.responsiveHeight(phoneVal: 24, tabletVal: 32),
              width: sizes!.responsiveWidth(phoneVal: 24, tabletVal: 32),
            ),
            ConstPadding.sizeBoxWithWidth(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GetGenericText(
                  text: title,
                  fontSize: sizes!.responsiveFont(phoneVal: 14, tabletVal: 16),
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey6Color,
                ),
                GetGenericText(
                  text: subtitle,
                  fontSize: sizes!.responsiveFont(phoneVal: 11, tabletVal: 13),
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey3Color,
                ),
              ],
            ),
            Visibility(
              visible: isSecondIcon,
              child: const Spacer(),
            ),
            Visibility(
              visible: isSecondIcon,
              child: SvgPicture.asset(
                "assets/svg/fill_icon.svg",
                height: sizes!.responsiveHeight(phoneVal: 24, tabletVal: 32),
                width: sizes!.responsiveWidth(phoneVal: 24, tabletVal: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
