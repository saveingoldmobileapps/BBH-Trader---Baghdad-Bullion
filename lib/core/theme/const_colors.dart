import 'package:flutter/material.dart';

/// Created by Tayyab Mughal on 03/11/2023.
/// Brand palette from BBH style guide + existing app neutrals.

class AppColors {
  /// Brand — from style guide
  // static const brandGold1 = Color(0xFFbb912f);
  // static const brandGold2 = Color(0xFFb19e5c);
  // static const brandGold3 = Color(0xFFcfc78c);
  // static const brandGold4 = Color(0xFFaa8a2a);
  static const brandWhite = Color(0xFFFFFFFF);
  static const brandDark = Color(0xFF161616);

 // ✅ FIXED: Use vertical gradient (top to bottom) - this matches your first image
//   static const brandGold1 = Color(0xFFB19E5C);
// static const brandGold2 = Color(0xFFCFC78C);
// static const brandGold3 = Color(0xFFBB912F);
// static const brandGold4 = Color(0xFFAA8A2A);
static const brandGold1 = Color(0xFFBB912F); // Dark gold
static const brandGold2 = Color(0xFFB19E5C); // Medium gold  
static const brandGold3 = Color(0xFFCFC78C); // Light gold
static const brandGold4 = Color(0xFFAA8A2A); // Deep gold

static const brandGoldGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color(0xFFAA8A2A), // Deep gold - left edge (dark)
    Color(0xFFBB912F), // Dark gold
    Color(0xFFB19E5C), // Medium gold
    Color(0xFFCFC78C), // Light gold - center (brightest)
    Color(0xFFB19E5C), // Medium gold
    Color(0xFFBB912F), // Dark gold
    Color(0xFFAA8A2A), // Deep gold - right edge (dark)
  ],
  stops: [
    0.0,   // 0% - Left edge (dark)
    0.15,  // 15%
    0.35,  // 35%
    0.50,  // 50% - Center (lightest)
    0.65,  // 65%
    0.85,  // 85%
    1.0,   // 100% - Right edge (dark)
  ],
);
// static const brandGoldGradient = LinearGradient(
//   begin: Alignment.centerLeft,
//   end: Alignment.centerRight,
//   colors: [
//     brandGold2,
//     brandGold1,
//     brandGold2,
//     brandGold4,
//     brandGold4,
//    // brandGold2,
//     //brandGold4,
//   ],
//   stops: [
//     0.00,
//     0.18,
//     0.40,
//     0.50,
//     0.68,
//   ],
// );


  // Diagonal gradient (top-left to bottom-right)
  static const brandGoldGradientDiagonal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandGold1, brandGold2, brandGold3, brandGold4],
  );

  // Horizontal gradient (left to right) - use this for progress bars or horizontal elements
  static const brandGoldGradientHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [brandGold1, brandGold2, brandGold3, brandGold4],
  );

  /// Colors
  static const primaryGold500 = brandGold2;
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
  static const goldDarkColor = brandGold4;
  static const greyScale1000 = brandDark;
  static const greyScale900 = Color.fromRGBO(51, 51, 51, 1);
  static const greyScale800 = Color.fromRGBO(83, 84, 86, 1);
  static const greyScale700 = Color.fromRGBO(131, 132, 132, 1);
  static const greyScale100 = Color.fromRGBO(168, 168, 168, 1);
  static const greyScale50 = Color.fromRGBO(197, 197, 197, 1);
  static const greyScale40 = Color.fromRGBO(217, 217, 217, 1);
  static const greyScale30 = Color.fromRGBO(234, 234, 234, 1);
  static const greyScale20 = Color.fromRGBO(247, 247, 247, 1);
  static const greyScale10 = Color.fromRGBO(234, 234, 234, 1);
  static const grey1Color = Color.fromRGBO(133, 133, 133, 1);
  static const whiteColor = brandWhite;
  static const barColor = Color.fromRGBO(222, 106, 76, 1);
  static const goldColor = brandGold2;
  static const goldLightColor = brandGold3;
  static const goldMoreLightColor = Color(0xFFE8D9A8);
  static const kScaffoldBackgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        brandGold1,
        brandGold4,
      ],
    ),
  );
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
