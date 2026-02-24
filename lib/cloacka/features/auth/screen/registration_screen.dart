import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:neomoney/app/di.dart';
import 'package:neomoney/cloacka/app/router/app_routes.dart';
import 'package:neomoney/cloacka/core/storage/app_prefs.dart';
import 'package:neomoney/cloacka/features/policy/widget/privacy_policy_widget.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _phoneMask = MaskTextInputFormatter(
    mask: '+7 ### ### ## ##',
    filter: {'#': RegExp(r'\d')},
  );

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');

  bool _isValidPhone(String raw) => _digitsOnly(raw).length == 11;

  void _showError(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    FocusScope.of(context).unfocus();

    final lastName = _lastNameController.text.trim();
    final firstName = _firstNameController.text.trim();
    final phoneRaw = _phoneController.text;

    if (lastName.isEmpty) {
      _showError('Введите фамилию');
      return;
    }

    if (firstName.isEmpty) {
      _showError('Введите имя');
      return;
    }

    if (!_isValidPhone(phoneRaw)) {
      _showError('Введите корректный номер телефона');
      return;
    }

    // TODO: здесь позже будет реальная регистрация через API.
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
        // resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    // ВАЖНО: никаких Spacer/Expanded
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 28),
                          const _AuthHeader(),
                          const SizedBox(height: 28),

                          _RegContent(
                            lastNameController: _lastNameController,
                            firstNameController: _firstNameController,
                            phoneController: _phoneController,
                            phoneMask: _phoneMask,
                          ),
                        ],
                      ),

                      Column(
                        children: [
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
              );
            },
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
      style: AppTypography.textTheme.titleLarge?.copyWith(
        color: AppColors.scaffold,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _RegContent extends StatelessWidget {
  final TextEditingController lastNameController;
  final TextEditingController firstNameController;
  final TextEditingController phoneController;
  final MaskTextInputFormatter phoneMask;

  const _RegContent({
    required this.lastNameController,
    required this.firstNameController,
    required this.phoneController,
    required this.phoneMask,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/icons/sms_bubble.png', height: 140, fit: BoxFit.contain),
        const SizedBox(height: 42),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              _AuthTextField(
                controller: lastNameController,
                hint: 'Фамилия',
                keyboardType: TextInputType.name,
                inputFormatters: const [],
              ),
              const SizedBox(height: 12),
              _AuthTextField(
                controller: firstNameController,
                hint: 'Имя',
                keyboardType: TextInputType.name,
                inputFormatters: const [],
              ),
              const SizedBox(height: 12),
              _AuthTextField(
                controller: phoneController,
                hint: 'Номер телефона',
                keyboardType: TextInputType.phone,
                inputFormatters: [phoneMask],
              ),
            ],
          ),
        ),

        SizedBox(height: MediaQuery.of(context).size.height < 700 ? 24 : 74),      ],
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;

  const _AuthTextField({
    required this.controller,
    required this.hint,
    required this.keyboardType,
    required this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: AppTypography.textTheme.titleMedium?.copyWith(
          color: const Color(0xFF2B2B2B),
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.textTheme.titleMedium?.copyWith(
            color: const Color(0xFF6E7485),
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          textStyle: AppTypography.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        child: Text(text),
      ),
    );
  }
}