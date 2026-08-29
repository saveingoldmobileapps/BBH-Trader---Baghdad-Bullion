// Created by Tayyab Mughal on 03/12/2022.
// Tayyab Mughal
// tayyabmughal676@gmail.com
// © 2022-2023  - All Rights Reserved

import 'package:flutter/material.dart';

import '../core_export.dart';

class GetGenericText extends StatelessWidget {
  final String text;
  final num fontSize;
  final FontWeight fontWeight;
  final Color color;

  final TextAlign textAlign;
  final int lines;
  final bool isUnderline;
  final bool isInter;
  final TextOverflow? overflow;

  const GetGenericText({
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
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context);
    final preferArabic = locale?.languageCode == 'ar';

    return Text(
      text,
      textAlign: textAlign,
      softWrap: true,
      maxLines: lines,
      overflow: overflow ?? TextOverflow.clip,
      style: AppFonts.text(
        fontSize: sizes!.fontRatio * fontSize,
        fontWeight: fontWeight,
        color: color,
        preferArabic: preferArabic,
        decoration: isUnderline ? TextDecoration.underline : null,
        decorationColor: isUnderline ? color : null,
      ),
    );
  }
}
