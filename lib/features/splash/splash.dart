import 'package:flutter/material.dart';
import 'package:neomoney/app/di.dart';
import 'package:neomoney/app/router.dart';
import 'package:neomoney/core/auth/token_storage.dart';

class AuthSplash extends StatefulWidget {
  const AuthSplash({super.key});

  @override
  State<AuthSplash> createState() => _AuthSplashState();
}

class _AuthSplashState extends State<AuthSplash> {
  bool _navigated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_navigated) return;
    _navigated = true;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final tokenStorage = getIt<TokenStorage>();
    final token = await tokenStorage.readAccessToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRouteNames.homeScreen, (r) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRouteNames.authScreen, (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}