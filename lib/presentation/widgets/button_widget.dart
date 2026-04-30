import 'package:flutter/material.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    super.key,
    required this.title,
    required this.isLoadingState,
    this.onTap,
    this.enabled = true,
  });

  final String title;
  final bool isLoadingState;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool isButtonEnabled = enabled && onTap != null;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: isButtonEnabled
              ? const LinearGradient(
                  begin: Alignment(1.00, 0.01),
                  end: Alignment(-1, -0.01),
                  colors: [
                    Color(0xFF74540E),
                    Color(0xFFB19454),
                  ],
                )
              : LinearGradient(
                  begin: const Alignment(1.00, 0.01),
                  end: const Alignment(-1, -0.01),
                  colors: [
                    Colors.grey.withValues(alpha: 0.6),
                    Colors.grey.withValues(alpha: 0.4),
                  ],
                ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: isButtonEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.grey.withValues(alpha: 0.3),
          highlightColor: Colors.grey.withValues(alpha: 0.15),
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
