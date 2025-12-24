import 'package:flutter/material.dart';

class AppSizes {
  late Size _screenSize;
  late bool isPhone;
  late bool isVerySmallPhone;
  late double width;
  late double height;
  late double topPadding;

  // For dynamic sizing
  late double widthRatio;
  late double heightRatio;
  late double fontRatio;

  late Orientation orientation;

  void initializeSize(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    topPadding = MediaQuery.of(context).padding.top;
    orientation = MediaQuery.of(context).orientation;

    width = _screenSize.shortestSide;
    height = _screenSize.longestSide;

    isPhone = width < 600;
    isVerySmallPhone = height <= 700; // Small devices

    if (isVerySmallPhone) {
      fontRatio = width / 360 * 0.75;
      widthRatio = width / 360 * 0.75;
      heightRatio = height / 720 * 0.75;
    } else if (isPhone) {
      fontRatio = width <= 360 ? width / 360 : 1.0;
      widthRatio = width / 360;
      heightRatio = height / 720;
    } else {
      fontRatio = 1.0;
      widthRatio = width / 900;
      heightRatio = height / 1200;
    }
  }

  double responsiveHeight({
    required double phoneVal,
    required double tabletVal,
  }) => isVerySmallPhone
      ? phoneVal *
            heightRatio *
            0.75 // Further reduced
      : isPhone
      ? phoneVal * heightRatio
      : tabletVal * heightRatio;

  double responsiveWidth({
    required double phoneVal,
    required double tabletVal,
  }) => isVerySmallPhone
      ? phoneVal *
            widthRatio *
            0.75 // Further reduced
      : isPhone
      ? phoneVal * widthRatio
      : tabletVal * widthRatio;

  double responsiveFont({
    required double phoneVal,
    required double tabletVal,
  }) => isVerySmallPhone
      ? phoneVal *
            0.75 // Smaller fonts for tiny screens
      : isPhone
      ? phoneVal
      : tabletVal;

  // Method to calculate responsive height for landscape mode
  double responsiveLandscapeHeight({
    required double phoneVal,
    required double tabletVal,
    required double tabletLandscapeVal,
    required bool isLandscape,
  }) {
    if (isVerySmallPhone) {
      return phoneVal * heightRatio * 0.75;
    }
    if (isPhone) {
      return phoneVal * heightRatio;
    }
    return isLandscape
        ? tabletLandscapeVal * heightRatio
        : tabletVal * heightRatio;
  }

  // Method to calculate responsive width for landscape mode
  double responsiveLandscapeWidth({
    required double phoneVal,
    required double tabletVal,
    required double tabletLandscapeVal,
    required bool isLandscape,
  }) {
    if (isVerySmallPhone) {
      return phoneVal * widthRatio * 0.75;
    }
    if (isPhone) {
      return phoneVal * widthRatio;
    }
    return isLandscape
        ? tabletLandscapeVal * widthRatio
        : tabletVal * widthRatio;
  }

  bool isLandscape() => orientation == Orientation.landscape;

  void refreshSize(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    width = _screenSize.width;
    height = _screenSize.height;
    orientation = MediaQuery.of(context).orientation;
  }
}
