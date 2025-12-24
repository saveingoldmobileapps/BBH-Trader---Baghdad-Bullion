import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';

class CustomKycAccountWarning extends StatelessWidget {
  final String kycStatus;
  final VoidCallback onTap;

  const CustomKycAccountWarning({
    required this.kycStatus,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              "assets/svg/alert_icon.svg",
              color: AppColors.green800Color,
            ),
            ConstPadding.sizeBoxWithWidth(width: 5),
            GetGenericText(
                    text: "$kycStatus approval in Process",
                    fontSize: sizes!.isPhone ? 12 : 16,
                    fontWeight: sizes!.isPhone
                        ? FontWeight.w400
                        : FontWeight.w600,
                    color: AppColors.whiteColor,
                    isInter: true,
                  ),
         
          ],
        ).get6VerticalPadding(),
      ),
    );
  }
}
