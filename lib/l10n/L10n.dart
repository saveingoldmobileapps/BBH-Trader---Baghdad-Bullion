import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('ar'),
  ];

  static String getLangName(String code) {
    switch (code) {
      case 'ar':
        return "Arabic";
      case 'en':
      default:
        return "English";
    }
  }
}
