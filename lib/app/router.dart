import 'package:flutter/material.dart';
import 'package:neomoney/app/di.dart';
import 'package:neomoney/cloacka/app/router/app_routes.dart';
import 'package:neomoney/cloacka/core/storage/app_prefs.dart';
import 'package:neomoney/cloacka/features/onboarding/screen/onboarding_screen.dart';
import 'package:neomoney/core/auth/token_storage.dart';
import 'package:neomoney/features/auth/auth_screen.dart';
import 'package:neomoney/features/auth/phone_auth_screen.dart';
import 'package:neomoney/features/home/home_screen.dart';
import 'package:neomoney/features/home/screens/fixation_selection_screen.dart';
import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';
import 'package:neomoney/features/home/screens/paymen_schedule_screen.dart';
import 'package:neomoney/features/registration/registration_flow_screen.dart';
import 'package:neomoney/features/splash/splash.dart';

abstract class AppRouteNames {
  static const String splash = '/';
  static const String authScreen = '/auth_screen';
  static const String homeScreen = '/home_screen';
  static const String loginPhone = '/login_phone';
  static const String registration = '/registration';
  static const String payment = '/payment_fixation';
  static const String paymentSchedule = '/payment_schedule';
  static const String registrationStepBankSelection = '/registration_step_bank_selection';
  static const String onboarding = '/onboarding';


}

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouteNames.splash:
        return _buildRoute(settings, const AuthSplash());

      case AppRouteNames.authScreen:
        return _buildRoute(settings, const AuthScreen());

      case AppRouteNames.homeScreen:
        return _buildRoute(settings, const HomeScreen());

      case AppRouteNames.loginPhone:
        return _buildRoute(settings, const LoginPhoneScreen());

      case AppRouteNames.registration:
        return _buildRoute(settings, const RegistrationFlowScreen());

      case AppRouteNames.onboarding:
        return _buildRoute(
          settings,
          OnboardingScreen(
            resolveNextRoute: () async {
              final prefs = getIt<AppPrefs>();
              final isCloaca = prefs.cloacaEnabled;

              if (isCloaca) {
                // cloaca: после онбординга -> cloaca auth/home
                return prefs.isAuthorized ? AppRoutesCloacka.home : AppRoutesCloacka.auth;
              } else {
                // main: после онбординга -> main auth/home
                final token = await getIt<TokenStorage>().readAccessToken();
                final authed = token != null && token.isNotEmpty;
                return authed ? AppRouteNames.homeScreen : AppRouteNames.authScreen;
              }
            },
          ),
        );

      case AppRouteNames.payment:
        final args = settings.arguments;
        final orders = args is List<OrderModel> ? args : <OrderModel>[];
        return _buildRoute(settings, FixationSelectionScreen(orders: orders));

      case AppRouteNames.paymentSchedule:
        final orderId = settings.arguments as int; // или Map
        return _buildRoute(settings, PaymentScheduleScreen(orderId: orderId));

        case AppRouteNames.registrationStepBankSelection:
        final orderId = settings.arguments as int; // или Map
        return _buildRoute(settings, PaymentScheduleScreen(orderId: orderId));

      default:
        return _buildRoute(settings, const _UnknownRouteScreen());
    }
  }

  static MaterialPageRoute _buildRoute(RouteSettings settings, Widget child) {
    return MaterialPageRoute(settings: settings, builder: (_) => child);
  }
}

/// Экран для неизвестных роутов
class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Unknown route')));
  }
}
