import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/core_export.dart';

class BuildPaymentMethodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconString;
  final VoidCallback onTap;

  const BuildPaymentMethodCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconString,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: sizes!.isPhone ? sizes!.widthRatio * 361 : sizes!.width,
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: Color(0xFF333333),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              iconString,
              height: sizes!.heightRatio * 24,
              width: sizes!.widthRatio * 24,
            ),
            ConstPadding.sizeBoxWithWidth(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GetGenericText(
                  text: title,
                  fontSize: sizes!.isPhone ? 14 : 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey6Color,
                ),
                GetGenericText(
                  text: subtitle,
                  fontSize: sizes!.isPhone ? 11 : 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey3Color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
