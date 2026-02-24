import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:neomoney/app/di.dart';
import 'package:neomoney/cloacka/core/storage/app_info_storage.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/validation/fio_rules.dart';
import 'package:neomoney/features/registration/cubit/registration_cubit.dart';
import 'package:neomoney/features/registration/cubit/registration_state.dart';
import 'package:url_launcher/url_launcher_string.dart';

class StepFullName extends StatefulWidget {
  const StepFullName({super.key});

  @override
  State<StepFullName> createState() => _StepFullNameState();
}

class _StepFullNameState extends State<StepFullName> {
  String? _lastNameError;
  String? _firstNameError;
  String? _middleNameError;

  void _validateSurname(String v) {
    setState(() => _lastNameError = FioRules.validate(v, FioFieldType.surname));
  }

  void _validateName(String v) {
    setState(() => _firstNameError = FioRules.validate(v, FioFieldType.name));
  }

  void _validatePatronymic(String v) {
    setState(() => _middleNameError = FioRules.validate(v, FioFieldType.patronymic));
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegistrationFlowCubit>();
    final appInfo = getIt<AppInfoStorage>();

    return BlocBuilder<RegistrationFlowCubit, RegistrationFlowState>(
      buildWhen: (prev, next) =>
      prev.step != next.step ||
          prev.lastName != next.lastName ||
          prev.firstName != next.firstName ||
          prev.middleName != next.middleName ||
          prev.birthDate != next.birthDate ||
          prev.email != next.email ||
          prev.isAgreementAccepted != next.isAgreementAccepted,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Input62(
              hint: 'Фамилия',
              initialValue: state.lastName,
              errorText: _lastNameError,
              inputFormatters: const [_FioAllowedInputFormatter()],
              onChanged: (v) {
                cubit.lastNameChanged(v);
                _validateSurname(v);
              },
              onFocusLost: () => _validateSurname(state.lastName),
            ),
            const SizedBox(height: 12),

            _Input62(
              hint: 'Имя',
              initialValue: state.firstName,
              errorText: _firstNameError,
              inputFormatters: const [_FioAllowedInputFormatter()],
              onChanged: (v) {
                cubit.firstNameChanged(v);
                _validateName(v);
              },
              onFocusLost: () => _validateName(state.firstName),
            ),
            const SizedBox(height: 12),

            _Input62(
              hint: 'Отчество',
              initialValue: state.middleName,
              errorText: _middleNameError,
              inputFormatters: const [_FioAllowedInputFormatter()],
              onChanged: (v) {
                cubit.middleNameChanged(v);
                _validatePatronymic(v);
              },
              onFocusLost: () => _validatePatronymic(state.middleName),
            ),
            const SizedBox(height: 12),

            // Дата рождения — как было
            _Input62(
              hint: 'Дата рождения',
              keyboardType: TextInputType.number,
              initialValue: state.birthDate == null ? '' : _formatDate(state.birthDate!),
              inputFormatters: const [_DdMmYyyyInputFormatter()],
              onChanged: (text) {
                final parsed = _tryParseDdMmYyyy(text);
                if (parsed != null) {
                  cubit.birthDateChanged(parsed);
                }
              },
            ),

            const SizedBox(height: 12),
            _Input62(
              hint: 'E-mail (Обязательно)',
              keyboardType: TextInputType.emailAddress,
              initialValue: state.email,
              onChanged: cubit.emailChanged,
            ),
            const SizedBox(height: 14),

            // чекбокс — как было
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    value: state.isAgreementAccepted,
                    onChanged: (v) => cubit.agreementChanged(v ?? false),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    side: const BorderSide(color: Color(0xFFBDBDBD)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final url = appInfo.privacyPolicyUrl;
                      if (url == null || url.trim().isEmpty) return;

                      final ok = await canLaunchUrlString(url);
                      if (!ok) return;

                      await launchUrlString(url, mode: LaunchMode.externalApplication);
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Я согласен на обработку и передачу персональных данных',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static String _formatDate(DateTime d) => DateFormat('dd.MM.yyyy', 'ru_RU').format(d);

  static DateTime? _tryParseDdMmYyyy(String text) {
    if (text.length != 10) return null;
    try {
      final d = int.parse(text.substring(0, 2));
      final m = int.parse(text.substring(3, 5));
      final y = int.parse(text.substring(6, 10));

      if (m < 1 || m > 12) return null;
      if (d < 1 || d > 31) return null;
      if (y < 1900 || y > DateTime.now().year) return null;

      final dt = DateTime(y, m, d);
      if (dt.year != y || dt.month != m || dt.day != d) return null;

      return dt;
    } catch (_) {
      return null;
    }
  }
}

/// Форматирует ввод в dd.MM.yyyy, допускает только цифры.
/// Пример: 01011990 -> 01.01.1990
class _DdMmYyyyInputFormatter extends TextInputFormatter {
  const _DdMmYyyyInputFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clamped = digits.length > 8 ? digits.substring(0, 8) : digits;

    final buffer = StringBuffer();
    for (int i = 0; i < clamped.length; i++) {
      buffer.write(clamped[i]);
      if (i == 1 || i == 3) buffer.write('.');
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _Input62 extends StatefulWidget {
  final String hint;
  final String initialValue;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  final String? errorText;
  final VoidCallback? onFocusLost;

  const _Input62({
    required this.hint,
    this.initialValue = '',
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.inputFormatters,
    this.errorText,
    this.onFocusLost,
  });

  @override
  State<_Input62> createState() => _Input62State();
}

class _Input62State extends State<_Input62> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        widget.onFocusLost?.call();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _Input62 oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialValue == widget.initialValue) return;

    if (!_focusNode.hasFocus && _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: TextField(
        focusNode: _focusNode,
        controller: _controller,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        readOnly: widget.readOnly,
        showCursor: !widget.readOnly,
        canRequestFocus: !widget.readOnly,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hint,
          errorText: widget.errorText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}

class _FioAllowedInputFormatter extends TextInputFormatter {
  const _FioAllowedInputFormatter();

  static final _allowedChar = RegExp(r"[А-Яа-яЁёIV\-\s\.,'\(\)]");

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final filtered = newValue.text.split('').where((c) => _allowedChar.hasMatch(c)).join();
    if (filtered == newValue.text) return newValue;
    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}
