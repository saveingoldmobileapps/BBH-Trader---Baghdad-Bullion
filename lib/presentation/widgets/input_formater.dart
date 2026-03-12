import 'package:flutter/services.dart';

class AmountInputFormatter extends TextInputFormatter {
  final int maxDigits;
  final int decimalRange;

  AmountInputFormatter({
    required this.maxDigits,
    this.decimalRange = 2,
  });

  late final RegExp _regex =
      RegExp(r'^\d{0,' + '$maxDigits' + r'}(\.\d{0,' + '$decimalRange' + r'})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_regex.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}