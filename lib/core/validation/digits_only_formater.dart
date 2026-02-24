import 'package:flutter/services.dart';

class DigitsOnlyMaxLengthFormatter extends TextInputFormatter {
  final int maxDigits;

  DigitsOnlyMaxLengthFormatter(this.maxDigits);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
    }

    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}