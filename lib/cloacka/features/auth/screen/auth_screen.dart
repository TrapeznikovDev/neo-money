import 'package:flutter/material.dart';
import 'package:neomoney/cloacka/app/router/app_routes.dart';
import 'package:neomoney/cloacka/features/policy/widget/privacy_policy_widget.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';

class AuthScreenCloacka extends StatelessWidget {
  const AuthScreenCloacka({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            _Background(),
            Positioned(left: 0, right: 0, top: 24, child: const _Header()),
            const Align(alignment: Alignment.center, child: _CenterContent()),
            PrivacyPolicyWidget()
          ],
        ),
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Container(color: AppColors.primary),

          Align(
            alignment: const Alignment(0, -0.25),
            child: Image.asset('assets/images/line.png', width: MediaQuery.of(context).size.width, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

class _CenterContent extends StatelessWidget {
  const _CenterContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/man1.png', height: 360, fit: BoxFit.contain),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutesCloacka.registration),
          child: Container(
            height: 58,
            width: 340,
            decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(30)),
            child: Center(
              child: Text(
                'Регистрация',
                style: AppTypography.textTheme.titleMedium?.copyWith(color: AppColors.scaffold, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutesCloacka.phoneAuth),
          child: Container(
            height: 58,
            width: 340,
            decoration: BoxDecoration(color: AppColors.scaffold, borderRadius: BorderRadius.circular(30)),
            child: Center(
              child: Text(
                'Войти',
                style: AppTypography.textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/icons/neomoney_logo.png'),
        SizedBox(height: 15),
        Text(
          'Регистрация и войти',
          style: AppTypography.textTheme.displayMedium?.copyWith(color: AppColors.scaffold, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
