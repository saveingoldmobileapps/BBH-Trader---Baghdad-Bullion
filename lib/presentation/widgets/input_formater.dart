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
class RoundedAmountInputFormatter extends TextInputFormatter {
  final int maxDigits;

  RoundedAmountInputFormatter({this.maxDigits = 6});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // 1. keep digits only
    text = text.replaceAll(RegExp(r'[^0-9]'), '');

    // 2. limit length
    if (text.length > maxDigits) {
      text = text.substring(0, maxDigits);
    }

    if (text.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // ⚠️ IMPORTANT:
    // Do NOT aggressively round while typing (this breaks input UX)

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}