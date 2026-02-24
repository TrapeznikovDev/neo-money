import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:neomoney/app/di.dart';
import 'package:neomoney/cloacka/app/router/app_router.dart';
import 'package:neomoney/cloacka/app/router/app_routes.dart';
import 'package:neomoney/core/ui/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeoMoney',
      navigatorKey: getIt<GlobalKey<NavigatorState>>(),
      onGenerateRoute: AppRouterCloacka.onGenerateRoute,
      theme: AppTheme.light,
      locale: const Locale('ru', 'RU'),
      supportedLocales: const [
        Locale('ru', 'RU'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutesCloacka.gate,
    );
  }
}