import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';

class LoaderArrowButton extends StatelessWidget {
  final String title;
  final bool isLoadingState;
  final VoidCallback onTap;

  const LoaderArrowButton({
    super.key,
    required this.title,
    this.isLoadingState = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: sizes!.isPhone ? sizes!.widthRatio * 360 : sizes!.width,
        height: sizes!.responsiveLandscapeHeight(
          phoneVal: 50,
          tabletVal: 60,
          tabletLandscapeVal: 70,
          isLandscape: sizes!.isLandscape(),
        ),
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment(1.00, 0.01),
            end: Alignment(-1, -0.01),
            colors: [
              Color(0xFF675A3D),
              Color(0xFFBBA473),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoadingState
            ? Center(
                child: Container(
                  width: sizes!.widthRatio * 26,
                  height: sizes!.widthRatio * 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GetGenericText(
                    text: title, //"Continue",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 18,
                      tabletVal: 20,
                    ),
                    //18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  ConstPadding.sizeBoxWithWidth(width: 10),
                  SvgPicture.asset(
                    "assets/svg/forward_arrow.svg",
                    height:
                        sizes!.heightRatio *
                        (sizes!.isPhone
                            ? 22
                            : (sizes!.isLandscape() ? 32 : 20)),
                    width:
                        sizes!.widthRatio *
                        (sizes!.isPhone
                            ? 22
                            : (sizes!.isLandscape() ? 32 : 20)),
                  ),
                ],
              ),
      ),
    );
  }
}
