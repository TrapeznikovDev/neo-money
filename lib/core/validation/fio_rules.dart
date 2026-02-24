enum FioFieldType { surname, name, patronymic }

class FioRules {
  static final RegExp _allowedChars = RegExp(r"^[А-Яа-яЁёIV\-\s\.,'\(\)]+$");
  static const String _specialChars = r".- ',()";

  static String? validate(String? v, FioFieldType type) {
    if (v == null) return 'Поле не может быть пустым';

    final raw = v;
    final value = raw.trim();

    if (value.isEmpty) return 'Поле не может быть пустым';

    if (!_allowedChars.hasMatch(value)) {
      return 'Недопустимые символы. Разрешены: русские буквы, пробел, -, ., \', ,, (, ), I, V';
    }

    if (RegExp(r"[a-z]").hasMatch(value)) {
      return 'Строчные латинские буквы недопустимы';
    }

    if (value.length == 1 && RegExp(r"^[IV]$").hasMatch(value)) {
      return 'Поле не может состоять только из I или V';
    }
    if (RegExp(r"^[IV]").hasMatch(value)) {
      return 'Поле не может начинаться с I или V';
    }

    final openCount = '('.allMatches(value).length;
    final closeCount = ')'.allMatches(value).length;
    if (openCount != closeCount) {
      return 'Скобки должны быть парными';
    }
    int balance = 0;
    for (final ch in value.split('')) {
      if (ch == '(') balance++;
      if (ch == ')') balance--;
      if (balance < 0) return 'Некорректное расположение скобок';
    }

    if (RegExp(r"[.\- ',()]{2,}").hasMatch(value)) {
      return 'Нельзя использовать два спецсимвола подряд (пробел, -, ., \', ,, (, ))';
    }

    final first = value[0];
    final last = value[value.length - 1];

    bool isSpecial(String c) => _specialChars.contains(c);

    if (first == ')') return 'Закрывающая скобка не может быть первой';
    if (last == '(') return 'Открывающая скобка не может быть последней';

    if (type == FioFieldType.surname) {
      if (isSpecial(first)) return 'Фамилия не может начинаться со спецсимвола';
      if (isSpecial(last)) return 'Фамилия не может заканчиваться спецсимволом';
    } else {
      const nameStartEndForbidden = "-' ,";
      bool isForbiddenStartEnd(String c) => nameStartEndForbidden.contains(c) || c == ' ';

      if (isForbiddenStartEnd(first)) return 'Поле не может начинаться со спецсимвола';
      if (isForbiddenStartEnd(last)) return 'Поле не может заканчиваться спецсимволом';

      if (first == '.') return 'Точка не может быть первой';
      if (value.length == 1 && value == '.') return 'Поле не может состоять только из точки';
    }

    return null;
  }
}