import 'package:flutter/foundation.dart';

class AppLogger {
  static void d(Object message) {
    if (kDebugMode) debugPrint('[DEBUG] $message');
  }

  static void i(Object message) {
    debugPrint('[INFO] $message');
  }

  static void e(Object message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[ERROR] $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
  }
}