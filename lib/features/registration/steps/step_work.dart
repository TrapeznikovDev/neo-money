import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/features/registration/cubit/registration_cubit.dart';
import 'package:neomoney/features/registration/cubit/registration_state.dart';

class StepWork extends StatelessWidget {
  const StepWork({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegistrationFlowCubit>();

    return BlocBuilder<RegistrationFlowCubit, RegistrationFlowState>(
      buildWhen: (p, n) =>
          p.workPlace != n.workPlace ||
          p.workAddress != n.workAddress ||
          p.workSalary != n.workSalary ||
          p.professionValue != n.professionValue ||
          p.workScope != n.workScope ||
          p.isProfessionOpen != n.isProfessionOpen ||
          p.professionSuggestions != n.professionSuggestions ||
          p.isWorkPlaceLoading != n.isWorkPlaceLoading ||
          p.workPlaceSuggestions != n.workPlaceSuggestions,
      builder: (context, s) {
        final displayedPosition = s.workScope ?? s.professionValue ?? '';
        final isSpecialScope = s.workScope == 'Пенсионер' || s.workScope == 'Самозанятый';

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
            cubit.closeProfessionDropdown();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Input62(
                hint: 'Место работы',
                keyboardType: TextInputType.text,
                initialValue: s.workPlace,
                onChanged: isSpecialScope ? null : cubit.workPlaceChanged,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[А-Яа-яЁё0-9\s.,\-№–«»()]'))],
                enabled: !isSpecialScope,
              ),

              if (s.isWorkPlaceLoading) ...[const SizedBox(height: 8), const LinearProgressIndicator()],

              if (!s.isWorkPlaceLoading && s.workPlaceSuggestions.isNotEmpty) ...[
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(12),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: s.workPlaceSuggestions.length.clamp(0, 8),
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final item = s.workPlaceSuggestions[i];
                        return ListTile(
                          dense: true,
                          title: Text(item.name),
                          subtitle: item.address.isEmpty ? null : Text(item.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                          onTap: () => cubit.workPlaceSelected(item),
                        );
                      },
                    ),
                  ),
                ),
              ],

              _Input62(
                hint: 'Адрес организации',
                keyboardType: TextInputType.text,
                initialValue: s.workAddress,
                onChanged: isSpecialScope ? null : cubit.workAddressChanged,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[А-Яа-яЁё0-9\s.,\-№–«»()]'))],
                enabled: !isSpecialScope,
              ),

              // ===== Должность + встроенный список =====
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Input62(
                    hint: 'Должность',
                    readOnly: true,
                    initialValue: displayedPosition,
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      cubit.openProfessionDropdown();
                    },
                  ),

                  if (s.isProfessionOpen && s.professionSuggestions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(12),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: s.professionSuggestions.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final text = s.professionSuggestions[i];
                            return ListTile(
                              dense: true,
                              title: Text(text),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                cubit.professionSelected(text);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              _Input62(
                hint: 'Доход в месяц',
                keyboardType: TextInputType.number,
                initialValue: s.workSalary,
                onChanged: cubit.workSalaryChanged,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _WorkScopeRadio(
                    title: 'Пенсионер',
                    selected: s.workScope == 'Пенсионер',
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      cubit.closeProfessionDropdown();
                      cubit.workScopeSelected('Пенсионер');
                    },
                  ),
                  const SizedBox(width: 20),
                  _WorkScopeRadio(
                    title: 'Самозанятый',
                    selected: s.workScope == 'Самозанятый',
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      cubit.closeProfessionDropdown();
                      cubit.workScopeSelected('Самозанятый');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
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
  final bool enabled;

  const _Input62({
    required this.hint,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.initialValue = '',
    this.inputFormatters,
    this.enabled = true,
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
        enabled: widget.enabled,
        focusNode: _focus,
        controller: _controller,
        keyboardType: widget.keyboardType,
        readOnly: widget.readOnly,
        onTap: () {
          if (widget.readOnly) {
            FocusScope.of(context).unfocus();
            widget.onTap?.call();
          } else {
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

class _WorkScopeRadio extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _WorkScopeRadio({required this.title, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDADADA)),
                borderRadius: BorderRadius.circular(100),
                color: selected ? AppColors.primary : Colors.white,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
