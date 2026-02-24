import 'package:flutter/material.dart';
import 'package:neomoney/app/navigation/app_navigator.dart';

class AppToast {
  static void showError(String message) {
    final ctx = AppNavigator.context;
    if (ctx == null) return;

    ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}