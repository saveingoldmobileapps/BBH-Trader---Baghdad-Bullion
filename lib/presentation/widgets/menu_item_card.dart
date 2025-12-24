import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';

class MenuItemCard extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;

  const MenuItemCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: sizes!.responsiveWidth(
          phoneVal: 302,
          tabletVal: 402,
        ),
        height: sizes!.responsiveLandscapeHeight(
          phoneVal: 46,
          tabletVal: 58,
          tabletLandscapeVal: 82,
          isLandscape: sizes!.isLandscape(),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: sizes!.widthRatio * 12,
          vertical: sizes!.heightRatio * 8,
        ),
        decoration: ShapeDecoration(
          gradient:Directionality.of(context) == TextDirection.rtl? 
           LinearGradient(
            begin: Alignment(-1, 0),
            end: Alignment(1.00, 0.00),
            colors: [
              Color.fromRGBO(0, 0, 0, 0.1),
              Color.fromRGBO(0, 0, 0, 0.01),
            ],
          ):
          LinearGradient(
            begin: Alignment(1.00, 0.00),
            end: Alignment(-1, 0),
            colors: [
              Color.fromRGBO(0, 0, 0, 0.01),
              Color.fromRGBO(0, 0, 0, 0.1),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              height: sizes!.responsiveHeight(
                phoneVal: 16,
                tabletVal: 32,
              ),
              width: sizes!.responsiveWidth(
                phoneVal: 16,
                tabletVal: 32,
              ),
              color: AppColors.greyScale1000,
            ),
            ConstPadding.sizeBoxWithWidth(width: 10),
            GetGenericText(
              text: title,
              fontSize: sizes!.responsiveFont(
                phoneVal: 14,
                tabletVal: 16,
              ),
              fontWeight: FontWeight.w500,
              color: AppColors.greyScale1000,
            ),
          ],
        ),
      ),
    );
  }
}
