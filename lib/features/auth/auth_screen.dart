import 'package:flutter/material.dart';
import 'package:neomoney/app/di.dart';
import 'package:neomoney/app/router.dart';
import 'package:neomoney/core/presentation/base_bloc_page.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/core/ui/widgets/politic_section.dart';
import 'package:neomoney/features/auth/cubit/auth_cubit.dart';
import 'package:neomoney/features/auth/cubit/auth_state.dart';

class AuthScreen extends BaseBlocPage<AuthCubit, AuthState> {
  const AuthScreen({super.key});

  @override
  AuthCubit createBloc(BuildContext context) => getIt<AuthCubit>();

  @override
  bool get automaticallyImplyLeading => false;

  @override
  bool get useAppBar => false;

  @override
  String? get title => null;

  @override
  Color? get backgroundColor => AppColors.background;

  @override
  void onStateChanged(BuildContext context, AuthState state) {
    if (state.status == UiStatus.success) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRouteNames.homeScreen, (r) => false);
    }
  }

  @override
  Widget buildBody(BuildContext context, AuthState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 22),
              _TaglineCard(),
              const SizedBox(height: 20),
              Text('Получите заём под 0%', style: AppTypography.textTheme.titleLarge?.copyWith(fontSize: 26, fontWeight: FontWeight.w600)),
              SizedBox(height: 10),
              Image.asset('assets/images/auth_ads_image.png'),
              const SizedBox(height: 20),
              _PrimaryActionButtons(onRegister: () {}, onLogin: () {}, isLoading: state.status == UiStatus.loading),
              SizedBox(height: MediaQuery.of(context).size.height * 0.14),
              const PoliticSection(),
            ],
          ),
        );
      },
    );
  }
}

class _TaglineCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: const Center(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Займы ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
              ),
              TextSpan(
                text: 'без страховок!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _PrimaryActionButtons extends StatelessWidget {
  final VoidCallback onRegister;
  final VoidCallback onLogin;
  final bool isLoading;

  const _PrimaryActionButtons({required this.onRegister, required this.onLogin, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // SizedBox(
        //   height: 56,
        //   child: ElevatedButton(
        //     onPressed: isLoading ? null : () => Navigator.of(context).pushNamed(AppRouteNames.registration),
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: primaryColor,
        //       foregroundColor: Colors.white,
        //       textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        //     ),
        //     child: const Text('Регистрация'),
        //   ),
        // ),
        // const SizedBox(height: 12),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    Navigator.of(context).pushNamed(AppRouteNames.loginPhone);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primaryColor,
              elevation: 0,
              side: BorderSide(color: primaryColor.withOpacity(0.15), width: 1),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            child: const Text('Войти'),
          ),
        ),
      ],
    );
  }
}
