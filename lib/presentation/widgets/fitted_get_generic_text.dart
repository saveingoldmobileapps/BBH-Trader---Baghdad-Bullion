import 'package:flutter/material.dart';

import '../../core/theme/get_generic_text_widget.dart';

/// [GetGenericText] wrapped so large values scale down instead of overflowing.
/// Use inside a [Row] as a [Flexible] child so width is bounded.
class FittedGetGenericText extends StatelessWidget {
  const FittedGetGenericText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    required this.color,
    this.lines = 2,
    this.textAlign = TextAlign.start,
    this.isUnderline = false,
    this.isInter = false,
    this.overflow,
    this.alignment = Alignment.centerRight,
  });

  final String text;
  final num fontSize;
  final FontWeight fontWeight;
  final Color color;
  final int lines;
  final TextAlign textAlign;
  final bool isUnderline;
  final bool isInter;
  final TextOverflow? overflow;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment,
      child: GetGenericText(
        text: text,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        lines: lines,
        textAlign: textAlign,
        isUnderline: isUnderline,
        isInter: isInter,
        overflow: overflow,
      ),
    );
  }
}
