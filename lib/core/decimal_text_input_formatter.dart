import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({required this.decimalRange})
    : assert(decimalRange > 0);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text == '') {
      return newValue;
    }

    // Allow only digits and a single decimal point
    if (text.contains(RegExp(r'[^0-9.]'))) {
      return oldValue;
    }

    // Allow only one decimal point
    if (text.indexOf('.') != text.lastIndexOf('.')) {
      return oldValue;
    }

    // Allow maximum of `decimalRange` digits after the decimal point
    if (text.contains('.')) {
      final parts = text.split('.');
      if (parts.length > 1 && parts[1].length > decimalRange) {
        return oldValue;
      }
    }

    return newValue;
  }
}
