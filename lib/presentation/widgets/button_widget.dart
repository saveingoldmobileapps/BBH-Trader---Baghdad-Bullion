import 'package:flutter/material.dart';
import 'package:saveingold_fzco/core/core_export.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    super.key,
    required this.title,
    required this.isLoadingState,
    required this.onTap,
  });

  final String title;
  final bool isLoadingState;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          Colors.transparent, // Keep background transparent for custom gradient
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(1.00, 0.01),
            end: Alignment(-1, -0.01),
            colors: [
              Color(0xFFBBA473),
              Color(0xFF675A3D),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.grey.withValues(alpha: 0.3),
          // Light grey ripple
          highlightColor: Colors.grey.withValues(alpha: 0.15),
          // Tap down highlight
          child: Container(
            height: sizes!.responsiveLandscapeHeight(
              phoneVal: 56,
              tabletVal: 56,
              tabletLandscapeVal: 84,
              isLandscape: sizes!.isLandscape(),
            ),
            width: sizes!.width,
            alignment: Alignment.center,
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
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }
}
