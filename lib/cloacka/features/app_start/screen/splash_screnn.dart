import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  final double opacity;

  const SplashScreen({super.key, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: const Center(
          child: Image(
            image: AssetImage('assets/icons/app_logo.png'),
            width: 180,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}