import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../core_export.dart';

class Toasts {
  static Future<void> getErrorToast({
    required String text,
    ToastGravity gravity = ToastGravity.TOP,
    Duration duration = const Duration(seconds: 5),
  }) async {
    await Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity, // Use the passed gravity (or default to BOTTOM)
      timeInSecForIosWeb: duration.inSeconds,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: sizes!.fontRatio * 16.0,
    );
  }

  
  static Future<void> getSuccessToast({
    required String text,
    ToastGravity gravity = ToastGravity.TOP,
    Duration duration = const Duration(seconds: 5), // Add duration parameter
  }) async {
    await Fluttertoast.showToast(
      msg: text,
      toastLength: duration.inSeconds <= 2 ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG,
      gravity: gravity,
      timeInSecForIosWeb: duration.inSeconds,
      backgroundColor: Colors.green, // Assuming success toast is green
      textColor: Colors.white,
      fontSize: sizes!.fontRatio * 16.0,
    );
  }

  static Future<void> getWarningToast({
    required String text,
  }) async {
    await Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      fontSize: sizes!.fontRatio * 16.0,
    );
  }
}
