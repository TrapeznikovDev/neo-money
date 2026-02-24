import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Оставляем только цифры
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Убираем ведущий 7/8, если пользователь её ввёл
    if (digits.startsWith('7') || digits.startsWith('8')) {
      digits = digits.substring(1);
    }

    // Ограничиваем 10 цифрами (формат +7 (XXX) XXX-XX-XX)
    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    final buffer = StringBuffer('+7 ');

    if (digits.isNotEmpty) {
      buffer.write('(');
      final firstPart = digits.length >= 3 ? digits.substring(0, 3) : digits;
      buffer.write(firstPart);

      if (digits.length >= 3) {
        buffer.write(') ');
      }

      if (digits.length > 3) {
        final secondPart =
        digits.length >= 6 ? digits.substring(3, 6) : digits.substring(3);
        buffer.write(secondPart);
      }

      if (digits.length > 6) {
        final thirdPart =
        digits.length >= 8 ? digits.substring(6, 8) : digits.substring(6);
        buffer.write('-$thirdPart');
      }

      if (digits.length > 8) {
        final fourthPart =
        digits.length >= 10 ? digits.substring(8, 10) : digits.substring(8);
        buffer.write('-$fourthPart');
      }
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}