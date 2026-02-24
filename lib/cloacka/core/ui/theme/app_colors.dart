import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Основной брендовый цвет
  static const Color primary = Color.fromRGBO(13, 143, 242, 1);

  // Дополнительные цвета
  static const Color secondary = Color.fromRGBO(241, 244, 250, 1);
  static const Color buttonColor = Color.fromRGBO(229, 243, 255, 1);
  static const Color backColor = Color.fromRGBO(250, 250, 250, 1);

  // Бэкграунды
  static const Color background = Color(0xFFF5F7FA);
  static const Color scaffold = Color(0xFFFFFFFF);
  static const Color mainScaffold = Color.fromRGBO(255, 255, 255, 1);

  // Текст
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color greyBackground = Color.fromRGBO(245, 247, 250, 1);
  static const Color cardBackground = Color.fromRGBO(239, 248, 255, 1);
  static const Color textSecondary = Color.fromRGBO(105, 110, 130, 1);
  static const Color textGrey = Color.fromRGBO(30, 38, 46, 1);

  // Ошибка
  static const Color error = Color(0xFFDC3545);

  // Успех / подтверждение
  static const Color success = Color.fromRGBO(51, 185, 112, 1);

  // Light / dark вспомогательные
  static const Color border = Color(0xFFE6E6E6);
  static const Color disabled = Color.fromRGBO(249, 253, 248, 1);
}