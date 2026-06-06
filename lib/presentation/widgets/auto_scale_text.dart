import 'package:flutter/material.dart';

/// Shrinks text when it would overflow the available width (e.g. long IQD amounts).
class AutoScaleText extends StatelessWidget {
  const AutoScaleText({
    super.key,
    required this.text,
    required this.style,
    this.maxLines = 3,
    this.textAlign = TextAlign.start,
    this.alignment = Alignment.centerLeft,
  });

  final String text;
  final TextStyle style;
  final int maxLines;
  final TextAlign textAlign;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: Text(
              text,
              style: style,
              maxLines: maxLines,
              softWrap: true,
              textAlign: textAlign,
            ),
          ),
        );
      },
    );
  }
}
