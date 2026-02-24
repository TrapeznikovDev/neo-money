import 'package:flutter/material.dart';
import 'package:neomoney/app/di.dart';
import 'package:neomoney/app/router.dart';
import 'package:neomoney/cloacka/core/storage/app_prefs.dart';
import 'package:neomoney/cloacka/features/auth/screen/auth_screen.dart';
import 'package:neomoney/cloacka/features/auth/screen/registration_screen.dart';
import 'package:neomoney/cloacka/features/home/home.dart';
import 'package:neomoney/cloacka/features/home/screens/planned_purchase_add_stub_screen.dart';
import 'package:neomoney/cloacka/features/home/screens/progress_levels_screen.dart';
import 'package:neomoney/cloacka/features/policy/privacy_policy_screen.dart';
import 'package:neomoney/core/auth/token_storage.dart';
import 'package:neomoney/features/auth/phone_auth_screen.dart' as main_auth_phone;
import 'package:neomoney/features/home/screens/fixation_selection_screen.dart' as main_fix_screen;
import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';
import 'package:neomoney/features/home/screens/paymen_schedule_screen.dart' as main_payment_screen;
import 'package:neomoney/features/registration/registration_flow_screen.dart' as main_reg_phone;
import 'app_routes.dart';
import '../../features/app_start/screen/app_start_gate.dart';
import '../../features/auth/screen/phone_auth_screen.dart';
import '../../features/onboarding/screen/onboarding_screen.dart';
import 'package:neomoney/app/router.dart' as main_routes;
import 'package:neomoney/features/auth/auth_screen.dart' as main_auth;
import 'package:neomoney/features/home/home_screen.dart' as main_home;

class AppRouterCloacka {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutesCloacka.gate:
        return _page(const AppStartGate(), settings);

      case AppRoutesCloacka.phoneAuth:
        return _page(const PhoneAuthScreen(), settings);

      case AppRoutesCloacka.registration:
        return _page(const RegistrationScreen(), settings);

      case AppRoutesCloacka.auth:
        return _page(const AuthScreenCloacka(), settings);

      case AppRoutesCloacka.home:
        return _page(const HomeScreen(), settings);

      case AppRoutesCloacka.plannedPurchaseAdd:
        return _page(const PlannedPurchaseAddScreen(), settings);

      case AppRoutesCloacka.privacyPolicy:
        return _page(const PrivacyPolicyScreen(), settings);

      case AppRoutesCloacka.onboarding:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OnboardingScreen(
            resolveNextRoute: () async {
              final prefs = getIt<AppPrefs>();
              final isCloaca = prefs.cloacaEnabled;

              if (isCloaca) {
                return prefs.isAuthorized ? AppRoutesCloacka.home : AppRoutesCloacka.auth;
              } else {
                final token = await getIt<TokenStorage>().readAccessToken();
                final authed = token != null && token.isNotEmpty;
                return authed ? AppRouteNames.homeScreen : AppRouteNames.authScreen;
              }
            },
          ),
        );

      case AppRoutesCloacka.progressLevels:
        return _page(const ProgressLevelsScreen(), settings);

      case main_routes.AppRouteNames.authScreen:
        return _page(const main_auth.AuthScreen(), settings);

      case main_routes.AppRouteNames.homeScreen:
        return _page(const main_home.HomeScreen(), settings);

      case main_routes.AppRouteNames.loginPhone:
        return _page(const main_auth_phone.LoginPhoneScreen(), settings);

      case main_routes.AppRouteNames.registration:
        return _page(const main_reg_phone.RegistrationFlowScreen(), settings);

      case main_routes.AppRouteNames.payment:
        final args = settings.arguments;
        final orders = args is List<OrderModel> ? args : <OrderModel>[];
        return _page(main_fix_screen.FixationSelectionScreen(orders: orders), settings);

      case main_routes.AppRouteNames.paymentSchedule:
        final orderId = settings.arguments as int; // или Map
        return _page(main_payment_screen.PaymentScheduleScreen(orderId: orderId), settings);

      default:
        return _page(const _UnknownRouteScreen(), settings);
    }
  }

  static MaterialPageRoute _page(Widget child, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Unknown route')));
  }
}
