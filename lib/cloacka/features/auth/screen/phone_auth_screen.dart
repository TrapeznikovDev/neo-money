import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:neomoney/app/di.dart';
import 'package:neomoney/cloacka/app/router/app_routes.dart';
import 'package:neomoney/cloacka/core/storage/app_info_storage.dart';
import 'package:neomoney/cloacka/core/storage/app_prefs.dart';
import 'package:neomoney/cloacka/features/policy/widget/privacy_policy_widget.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  bool _isCodeStep = false;

  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  final _phoneMask = MaskTextInputFormatter(mask: '+7 ### ### ## ##', filter: {'#': RegExp(r'\d')});

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');

  bool _isValidPhone(String raw) => _digitsOnly(raw).length == 11;

  bool _isValidCode(String raw) => RegExp(r'^\d{4}$').hasMatch(raw);

  void _showError(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async{
    FocusScope.of(context).unfocus();

    final appInfo = getIt<AppInfoStorage>();

    print(appInfo.authPhone);

    final expectedPhone = _digitsOnly(appInfo.authPhone ?? '');
    final expectedCode = _digitsOnly(appInfo.authCode ?? '');

    if (!_isCodeStep) {
      final enteredPhone = _digitsOnly(_phoneController.text);

      if (!_isValidPhone(_phoneController.text)) {
        _showError('Введите корректный номер телефона');
        return;
      }

      if (expectedPhone.isEmpty) {
        _showError('Тестовый номер не загружен (authPhone пустой)');
        return;
      }

      if (enteredPhone != expectedPhone) {
        _showError('Неверный номер телефона');
        return;
      }

      setState(() => _isCodeStep = true);
      return;
    }

    final enteredCode = _digitsOnly(_codeController.text);

    if (!_isValidCode(enteredCode)) {
      _showError('Код должен состоять из 4 цифр');
      return;
    }

    if (expectedCode.isEmpty) {
      _showError('Тестовый код не загружен (authCode пустой)');
      return;
    }

    if (enteredCode != expectedCode) {
      _showError('Неверный код');
      return;
    }

    await getIt<AppPrefs>().setAuthorized();

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
    AppRoutesCloacka.home,
    (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.primary,
        body: SafeArea(
          bottom: true,
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 28),
                  const _AuthHeader(),
                  const SizedBox(height: 28),

                  Expanded(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          final slide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation);
                          return SlideTransition(
                            position: slide,
                            child: FadeTransition(opacity: animation, child: child),
                          );
                        },
                        child: _isCodeStep
                            ? _AuthContent(
                                key: const ValueKey('code'),
                                iconAsset: 'assets/icons/sms_bubble.png',
                                controller: _codeController,
                                hint: 'Введите код из СМС',
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                                keyboardType: TextInputType.number,
                              )
                            : _AuthContent(
                                key: const ValueKey('phone'),
                                iconAsset: 'assets/icons/sms_bubble.png',
                                controller: _phoneController,
                                hint: 'Введите номер телефона',
                                inputFormatters: [_phoneMask],
                                keyboardType: TextInputType.phone,
                              ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: _PrimaryButton(text: 'Далее', onPressed: _onNext),
                  ),

                  const SizedBox(height: 20),

                  const PrivacyPolicyWidget(),

                  const SizedBox(height: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Neomoney',
      style: AppTypography.textTheme.titleLarge?.copyWith(color: AppColors.scaffold, fontWeight: FontWeight.w700),
    );
  }
}

class _AuthContent extends StatelessWidget {
  final String iconAsset;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;

  const _AuthContent({
    super.key,
    required this.iconAsset,
    required this.controller,
    required this.hint,
    required this.keyboardType,
    required this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(iconAsset, height: 140, fit: BoxFit.contain),
        const SizedBox(height: 42),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _AuthTextField(controller: controller, hint: hint, keyboardType: keyboardType, inputFormatters: inputFormatters),
        ),

        const SizedBox(height: 74),
      ],
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;

  const _AuthTextField({required this.controller, required this.hint, required this.keyboardType, required this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: AppTypography.textTheme.titleMedium?.copyWith(color: const Color(0xFF2B2B2B), fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.textTheme.titleMedium?.copyWith(color: const Color(0xFF6E7485), fontWeight: FontWeight.w600),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          textStyle: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        child: Text(text),
      ),
    );
  }
}
