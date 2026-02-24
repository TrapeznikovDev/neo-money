import 'package:flutter/material.dart';
import 'package:neomoney/app/router.dart';

abstract class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static void toAuthAndClear() {
    final ctx = context;
    if (ctx == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = Navigator.of(ctx);
      nav.pushNamedAndRemoveUntil(AppRouteNames.authScreen, (route) => false);
    });
  }
}