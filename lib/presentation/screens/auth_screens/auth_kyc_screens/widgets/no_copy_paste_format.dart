import 'package:flutter/services.dart';

class NoPasteTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // prevents pasting by only allowing single character input at a time
    if (newValue.text.length - oldValue.text.length > 1) {
      return oldValue;
    }
    return newValue;
  }
}