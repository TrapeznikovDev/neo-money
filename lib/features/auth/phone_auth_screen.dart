import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/app/di.dart';
import 'package:neomoney/app/router.dart';
import 'package:neomoney/core/presentation/base_bloc_page.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/widgets/politic_section.dart';
import 'package:neomoney/core/ui/widgets/social_icon_button.dart';
import 'package:neomoney/core/validation/phone_input_formater.dart';
import 'package:neomoney/features/auth/cubit/auth_cubit.dart';
import 'package:neomoney/features/auth/cubit/auth_state.dart';

class LoginPhoneScreen extends BaseBlocPage<AuthCubit, AuthState> {
  const LoginPhoneScreen({super.key});

  @override
  AuthCubit createBloc(BuildContext context) => getIt<AuthCubit>();

  @override
  bool get automaticallyImplyLeading => false;

  @override
  String? get title => null;

  @override
  void onStateChanged(BuildContext context, AuthState state) {
    if (state.status != UiStatus.success) return;
    if (state.nextRoute == AuthNextRoute.none) return;

    final cubit = context.read<AuthCubit>();

    switch (state.nextRoute) {
      case AuthNextRoute.home:
        Navigator.of(context).pushNamedAndRemoveUntil(AppRouteNames.homeScreen, (r) => false);
        break;

      case AuthNextRoute.registration:
        Navigator.of(context).pushNamedAndRemoveUntil(AppRouteNames.registration, (r) => false);
        break;

      case AuthNextRoute.none:
        break;
    }

    cubit.consumeNextRoute();
  }

  @override
  Widget buildBody(BuildContext context, AuthState state) {
    return _LoginPhoneBody(state: state);
  }
}

class _LoginPhoneBody extends StatefulWidget {
  final AuthState state;

  const _LoginPhoneBody({required this.state});

  @override
  State<_LoginPhoneBody> createState() => _LoginPhoneBodyState();
}

class _LoginPhoneBodyState extends State<_LoginPhoneBody> {
  late final TextEditingController _phoneController;
  late final TextEditingController _smsController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _smsController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final state = widget.state;
    final isCodeRequested = state.isCodeRequested;
    final bottomHeight = isCodeRequested ? 0.23 : 0.31;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 22),
          const SizedBox(height: 24),

          Text(
            'Введите номер телефона',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Для авторизации необходимо ввести\nВаш номер телефона.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 62,
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [PhoneInputFormatter()],
              decoration: const InputDecoration(hintText: 'Номер телефона*'),
              onChanged: authCubit.phoneChanged,
            ),
          ),

          if (isCodeRequested) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 62,
              child: TextField(
                textInputAction: TextInputAction.done,
                maxLength: 4,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                buildCounter: (_, {required int currentLength, required int? maxLength, required bool isFocused}) => null,
                controller: _smsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Код из СМС'),
                onChanged: authCubit.smsCodeChanged,
              ),
            ),
          ],

          const SizedBox(height: 20),
          SizedBox(
            height: 58,
            child: ElevatedButton(
              onPressed: state.status == UiStatus.loading
                  ? null
                  : () {
                      if (!isCodeRequested) {
                        authCubit.requestSmsCode();
                      } else {
                        authCubit.confirmSmsCode();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              child: Text(isCodeRequested ? 'Войти' : 'Получить код из СМС'),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).size.height * bottomHeight),
          const SizedBox(height: 16),

          const PoliticSection(),
        ],
      ),
    );
  }
}
