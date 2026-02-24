import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/core/validation/digits_only_formater.dart';
import 'package:neomoney/features/registration/cubit/registration_cubit.dart';
import 'package:neomoney/features/registration/cubit/registration_state.dart';

class StepPassport extends StatelessWidget {
  const StepPassport({super.key});

  static final _codeMask = MaskTextInputFormatter(mask: '###-###', filter: {"#": RegExp(r'\d')});
  static String _formatDate(DateTime d) => DateFormat('dd.MM.yyyy', 'ru_RU').format(d);

  static DateTime? _tryParseDdMmYyyy(String text) {
    if (text.length != 10) return null; // dd.MM.yyyy
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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegistrationFlowCubit>();

    return BlocBuilder<RegistrationFlowCubit, RegistrationFlowState>(
      buildWhen: (p, c) =>
          p.passportIssueDate != c.passportIssueDate ||
          p.passportSerial != c.passportSerial ||
          p.passportIssued != c.passportIssued ||
          p.birthPlace != c.birthPlace ||
          p.issuedBySuggestions != c.issuedBySuggestions ||
          p.isIssuedByLoading != c.isIssuedByLoading ||
          p.passportSubdivisionCode != c.passportSubdivisionCode ||
          p.gender != c.gender ||
          p.isBirthPlaceLoading != c.isBirthPlaceLoading ||
          p.birthPlaceSuggestions != c.birthPlaceSuggestions,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Input62(
              hint: 'Серия и номер паспорта',
              inputFormatters: [DigitsOnlyMaxLengthFormatter(10)],
              keyboardType: TextInputType.number,
              initialValue: state.passportSerial,
              onChanged: cubit.passportSerialChanged,
            ),
            const SizedBox(height: 12),

            _Input62(
              hint: 'Дата выдачи',
              keyboardType: TextInputType.number,
              initialValue: state.passportIssueDate == null ? '' : _formatDate(state.passportIssueDate!),
              inputFormatters: const [_DdMmYyyyInputFormatter()],
              onChanged: (text) {
                final parsed = _tryParseDdMmYyyy(text);
                if (parsed != null) {
                  cubit.passportIssueDateChanged(parsed);
                }
              },
            ),
            const SizedBox(height: 12),

            _Input62(
              hint: 'Код подразделения',
              keyboardType: TextInputType.number,
              initialValue: state.passportSubdivisionCode,
              onChanged: cubit.passportSubdivisionCodeChanged,
              inputFormatters: [_codeMask],
            ),
            const SizedBox(height: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Input62(
                  hint: 'Кем выдан',
                  keyboardType: TextInputType.text,
                  initialValue: state.passportIssued,
                  onChanged: cubit.passportIssuedChanged,
                ),

                if (state.isIssuedByLoading) ...[const SizedBox(height: 8), const LinearProgressIndicator()],

                if (state.issuedBySuggestions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(12),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: state.issuedBySuggestions.length,
                        physics: const ClampingScrollPhysics(),
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final text = state.issuedBySuggestions[i];
                          return ListTile(
                            dense: true,
                            title: Text(text),
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              context.read<RegistrationFlowCubit>().issuedBySelected(text);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _GenderItem(title: 'Мужчина', selected: state.gender == GenderUi.male, onTap: () => cubit.genderChanged(GenderUi.male)),
                const SizedBox(width: 38),
                _GenderItem(title: 'Женщина', selected: state.gender == GenderUi.female, onTap: () => cubit.genderChanged(GenderUi.female)),
              ],
            ),

            const SizedBox(height: 18),

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Input62(
                  hint: 'Место рождения',
                  keyboardType: TextInputType.text,
                  initialValue: state.birthPlace,
                  onChanged: cubit.birthPlaceChanged,
                ),

                if (state.isBirthPlaceLoading) ...[const SizedBox(height: 8), const LinearProgressIndicator()],

                if (!state.isBirthPlaceLoading && state.birthPlaceSuggestions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(12),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: state.birthPlaceSuggestions.length.clamp(0, 8),
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final text = state.birthPlaceSuggestions[i];
                          return ListTile(
                            dense: true,
                            title: Text(text),
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              context.read<RegistrationFlowCubit>().birthPlaceSelected(text);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  static void _showCupertinoDatePicker({required BuildContext context, required DateTime initial, required ValueChanged<DateTime> onPicked}) {
    DateTime temp = initial;

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Localizations.override(
          context: ctx,
          locale: const Locale('ru', 'RU'),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.only(top: 8),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 320,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          CupertinoButton(padding: EdgeInsets.zero, onPressed: () => Navigator.of(ctx).pop(), child: const Text('Отмена')),
                          const Spacer(),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              onPicked(temp);
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Готово'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: initial,
                        maximumDate: DateTime.now(),
                        onDateTimeChanged: (d) => temp = d,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Форматирует ввод в dd.MM.yyyy, допускает только цифры.
/// Пример: 01012020 -> 01.01.2020
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
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final String initialValue;
  final List<TextInputFormatter>? inputFormatters;

  const _Input62({
    required this.hint,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.initialValue = '',
    this.inputFormatters,
  });

  @override
  State<_Input62> createState() => _Input62State();
}

class _Input62State extends State<_Input62> {
  late final TextEditingController _controller;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focus = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _Input62 oldWidget) {
    super.didUpdateWidget(oldWidget);

    final shouldForceUpdate = widget.readOnly;
    final canUpdate = shouldForceUpdate || !_focus.hasFocus;

    if (canUpdate && oldWidget.initialValue != widget.initialValue && _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: TextField(
        focusNode: _focus,
        controller: _controller,
        keyboardType: widget.keyboardType,
        readOnly: widget.readOnly,
        onTap: () {
          if (widget.readOnly) {
            FocusScope.of(context).unfocus();
            widget.onTap?.call();
          }
        },
        onChanged: widget.onChanged,
        decoration: InputDecoration(hintText: widget.hint),
        inputFormatters: widget.inputFormatters,
      ),
    );
  }
}

class _GenderItem extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _GenderItem({required this.title, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RadioDot(selected: selected),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;

  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: selected ? AppColors.primary : const Color(0xFFBDBDBD), width: selected ? 7 : 1),
      ),
      child: Center(
        child: Container(
          width: selected ? 12 : 0,
          height: selected ? 12 : 0,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.secondary),
        ),
      ),
    );
  }
}
