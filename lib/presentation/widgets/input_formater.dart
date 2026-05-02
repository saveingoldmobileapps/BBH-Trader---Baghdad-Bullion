import 'package:flutter/services.dart';

class DecimalAmountInputFormatter extends TextInputFormatter {
  final int maxDigits;
  final int decimalRange;

  DecimalAmountInputFormatter({
    required this.maxDigits,
    this.decimalRange = 3,
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

class AmountInputFormatter extends TextInputFormatter {
  final int maxDigits;

  AmountInputFormatter({
    required this.maxDigits,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // ❌ Block decimal
    if (text.contains('.')) {
      return oldValue;
    }

    // ❌ Allow only digits
    if (!RegExp(r'^\d*$').hasMatch(text)) {
      return oldValue;
    }

    // ❌ Max length
    if (text.length > maxDigits) {
      return oldValue;
    }

    return newValue;
  }
}