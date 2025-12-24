import 'package:flutter/material.dart';
import 'package:saveingold_fzco/core/core_export.dart';

class LoaderButton extends StatelessWidget {
  final String title;
  final bool isLoadingState;
  final VoidCallback onTap;
  final double tabletLandscapeVal;

  const LoaderButton({
    super.key,
    required this.title,
    this.isLoadingState = false,
    required this.onTap,
    this.tabletLandscapeVal = 64,
  });

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = sizes!.isLandscape() && !sizes!.isPhone
        ? sizes!.height
        : sizes!.isPhone
        ? sizes!.widthRatio * 360
        : sizes!.width;

    final double buttonHeight = sizes!.responsiveLandscapeHeight(
      phoneVal: 50,
      tabletVal: 56,
      tabletLandscapeVal: tabletLandscapeVal,
      isLandscape: sizes!.isLandscape(),
    );

    return Material(
      color: Colors.transparent,
      child: Ink(
        width: buttonWidth,
        height: buttonHeight,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(1.00, 0.01),
            end: Alignment(-1, -0.01),
            colors: [
              Color(0xFF675A3D),
              Color(0xFFBBA473),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.grey.withValues(alpha: 0.3),
          highlightColor: Colors.grey.withValues(alpha: 0.15),
          child: Center(
            child: isLoadingState
                ? SizedBox(
                    width: sizes!.widthRatio * 26,
                    height: sizes!.widthRatio * 26,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : GetGenericText(
                    text: title,
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 18,
                      tabletVal: 20,
                    ),
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }
}
