import 'package:flutter/material.dart';

/// Created by Tayyab Mughal on 03/11/2023.
/// Tayyab Mughal
/// tayyabmughal676@gmail.com
/// © 2023-2024  - All Rights Reserved

class AppColors {
  /// Colors
  static const primaryGold500 = Color.fromRGBO(187, 164, 115, 1);
  static const neutral92 = Color.fromRGBO(236, 230, 240, 1);
  static const neutral90 = Color.fromRGBO(229, 225, 225, 1);
  static const neutral80 = Color.fromRGBO(201, 198, 197, 1);
  static const secondaryColor = Color.fromRGBO(117, 117, 117, 1);
  static const grey2Color = Color.fromRGBO(174, 174, 178, 1);
  static const grey3Color = Color.fromRGBO(199, 199, 204, 1);
  static const grey4Color = Color.fromRGBO(209, 209, 214, 1);
  static const grey5Color = Color.fromRGBO(229, 229, 234, 1);
  static const grey6Color = Color.fromRGBO(242, 242, 247, 1);
  static const grey7Color = Color.fromRGBO(142, 142, 147, 1);
  static const grey500Color = Color.fromRGBO(197, 197, 197, 1);

  static const redColor = Color.fromRGBO(235, 87, 87, 1);
  static const red900Color = Color.fromRGBO(255, 59, 48, 1);
  static const red800Color = Color.fromRGBO(76, 3, 9, 1);
  static const greenColor = Color.fromRGBO(39, 174, 96, 1);
  static const green900Color = Color.fromRGBO(12, 76, 43, 1);
  static const green800Color = Color.fromRGBO(52, 199, 89, 1);

  static const greyScale1000 = Color.fromRGBO(35, 35, 35, 1);
  static const greyScale900 = Color.fromRGBO(51, 51, 51, 1);
  static const greyScale800 = Color.fromRGBO(83, 84, 86, 1);
  static const greyScale700 = Color.fromRGBO(131, 132, 132, 1);
  static const greyScale100 = Color.fromRGBO(168, 168, 168, 1);
  static const greyScale50 = Color.fromRGBO(197, 197, 197, 1);
  static const greyScale40 = Color.fromRGBO(217, 217, 217, 1);
  static const greyScale30 = Color.fromRGBO(234, 234, 234, 1);
  static const greyScale20 = Color.fromRGBO(247, 247, 247, 1);
  static const greyScale10 = Color.fromRGBO(234, 234, 234, 1);

  static const whiteColor = Color.fromRGBO(255, 251, 247, 1);
  static const barColor = Color.fromRGBO(222, 106, 76, 1);
  static const goldColor = Color.fromRGBO(161, 129, 101, 1);
  static const goldLightColor = Color.fromRGBO(200, 158, 108, 1);
  static const goldMoreLightColor = Color.fromRGBO(232, 200, 160, 1);
}

class HexColor extends Color {
  HexColor({required final String hexColor})
    : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}
