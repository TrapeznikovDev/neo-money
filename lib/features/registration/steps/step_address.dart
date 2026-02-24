import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/features/registration/cubit/registration_cubit.dart';
import 'package:neomoney/features/registration/cubit/registration_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/features/registration/cubit/registration_cubit.dart';
import 'package:neomoney/features/registration/cubit/registration_state.dart';
import 'package:neomoney/features/registration/data/models/city_suggestions.dart';
import 'package:neomoney/features/registration/data/models/region_suggestions.dart';
import 'package:neomoney/features/registration/data/models/streets_suggestions.dart';

class StepPassportAddress extends StatelessWidget {
  const StepPassportAddress({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegistrationFlowCubit>();

    return BlocBuilder<RegistrationFlowCubit, RegistrationFlowState>(
      buildWhen: (p, n) =>
          p.region != n.region ||
          p.isRegionLoading != n.isRegionLoading ||
          p.regionSuggestions != n.regionSuggestions ||
          p.locality != n.locality ||
          p.isLocalityLoading != n.isLocalityLoading ||
          p.localitySuggestions != n.localitySuggestions ||
          p.street != n.street ||
          p.isStreetLoading != n.isStreetLoading ||
          p.streetSuggestions != n.streetSuggestions ||
          p.isSameAddress != n.isSameAddress ||
          p.regRegion != n.regRegion ||
          p.isRegRegionLoading != n.isRegRegionLoading ||
          p.regRegionSuggestions != n.regRegionSuggestions ||
          p.regLocality != n.regLocality ||
          p.isRegLocalityLoading != n.isRegLocalityLoading ||
          p.regLocalitySuggestions != n.regLocalitySuggestions ||
          p.regStreet != n.regStreet ||
          p.isRegStreetLoading != n.isRegStreetLoading ||
          p.regStreetSuggestions != n.regStreetSuggestions ||
          p.regHouse != n.regHouse ||
          p.regBuilding != n.regBuilding ||
          p.regFlat != n.regFlat,
      builder: (context, state) {
        final isSameAddress = state.isSameAddress;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Input62(hint: 'Область/Регион/Край (обязательно)', initialValue: state.region, forceSync: true, onChanged: cubit.regionChanged),
            if (state.isRegionLoading) ...[const SizedBox(height: 8), const LinearProgressIndicator()],
            if (!state.isRegionLoading && state.regionSuggestions.isNotEmpty) ...[
              _SuggestionsBox<RegionSuggestion>(
                items: state.regionSuggestions,
                titleOf: (x) => x.title,
                onTap: (x) {
                  FocusScope.of(context).unfocus();
                  cubit.regionSelected(x);
                },
              ),
            ],
            const SizedBox(height: 14),

            _Input62(hint: 'Населенный пункт (обязательно)', initialValue: state.locality, forceSync: true, onChanged: cubit.localityChanged),
            if (state.isLocalityLoading) ...[const SizedBox(height: 8), const LinearProgressIndicator()],
            if (!state.isLocalityLoading && state.localitySuggestions.isNotEmpty) ...[
              _SuggestionsBox<CitySuggestion>(
                items: state.localitySuggestions,
                titleOf: (x) => x.title,
                onTap: (x) {
                  FocusScope.of(context).unfocus();
                  cubit.localitySelected(x);
                },
              ),
            ],
            const SizedBox(height: 14),

            _Input62(hint: 'Улица', initialValue: state.street, forceSync: true, onChanged: cubit.streetChanged),
            if (state.isStreetLoading) ...[const SizedBox(height: 8), const LinearProgressIndicator()],
            if (!state.isStreetLoading && state.streetSuggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              _SuggestionsBox<StreetSuggestion>(
                items: state.streetSuggestions,
                titleOf: (x) => x.title,
                onTap: (x) {
                  FocusScope.of(context).unfocus();
                  cubit.streetSelected(x);
                },
              ),
            ],
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _Input62(
                    hint: 'Дом',
                    radius: 20,
                    keyboardType: TextInputType.number,
                    // initialValue: state.house,
                    // onChanged: cubit.houseChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Input62(
                    hint: 'Строение',
                    radius: 20,
                    // initialValue: state.building,
                    // onChanged: cubit.buildingChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Input62(
                    hint: 'Квартира',
                    radius: 20,
                    keyboardType: TextInputType.number,
                    // initialValue: state.flat,
                    // onChanged: cubit.flatChanged,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _GreenSwitch(value: isSameAddress, onChanged: cubit.sameAddressChanged),
                const SizedBox(width: 14),
                const Expanded(child: Text('Адрес регистрации совпадает с\nадресом проживания')),
              ],
            ),

            if (!isSameAddress) ...[
              const SizedBox(height: 18),
              Text(
                'Адрес регистрации',
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 14),

              _Input62(hint: 'Область/Регион/Край (регистрация)', initialValue: state.regRegion, forceSync: true, onChanged: cubit.regRegionChanged),
              if (state.isRegRegionLoading) ...[const SizedBox(height: 8), const LinearProgressIndicator()],
              if (!state.isRegRegionLoading && state.regRegionSuggestions.isNotEmpty) ...[
                _SuggestionsBox<RegionSuggestion>(
                  items: state.regRegionSuggestions,
                  titleOf: (x) => x.title,
                  onTap: (x) {
                    FocusScope.of(context).unfocus();
                    cubit.regRegionSelected(x);
                  },
                ),
              ],
              const SizedBox(height: 14),

              _Input62(hint: 'Населенный пункт (регистрация)', initialValue: state.regLocality, forceSync: true, onChanged: cubit.regLocalityChanged),
              if (state.isRegLocalityLoading) ...[const SizedBox(height: 8), const LinearProgressIndicator()],
              if (!state.isRegLocalityLoading && state.regLocalitySuggestions.isNotEmpty) ...[
                _SuggestionsBox<CitySuggestion>(
                  items: state.regLocalitySuggestions,
                  titleOf: (x) => x.title,
                  onTap: (x) {
                    FocusScope.of(context).unfocus();
                    cubit.regLocalitySelected(x);
                  },
                ),
              ],
              const SizedBox(height: 14),

              _Input62(hint: 'Улица (регистрация)', initialValue: state.regStreet, forceSync: true, onChanged: cubit.regStreetChanged),
              if (state.isRegStreetLoading) ...[const SizedBox(height: 8), const LinearProgressIndicator()],
              if (!state.isRegStreetLoading && state.regStreetSuggestions.isNotEmpty) ...[
                const SizedBox(height: 8),
                _SuggestionsBox<StreetSuggestion>(
                  items: state.regStreetSuggestions,
                  titleOf: (x) => x.title,
                  onTap: (x) {
                    FocusScope.of(context).unfocus();
                    cubit.regStreetSelected(x);
                  },
                ),
              ],
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _Input62(
                      hint: 'Дом',
                      radius: 20,
                      keyboardType: TextInputType.number,
                      initialValue: state.regHouse,
                      forceSync: true,
                      onChanged: cubit.regHouseChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Input62(
                      hint: 'Строение',
                      radius: 20,
                      initialValue: state.regBuilding,
                      forceSync: true,
                      onChanged: cubit.regBuildingChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Input62(
                      hint: 'Квартира',
                      radius: 20,
                      keyboardType: TextInputType.number,
                      initialValue: state.regFlat,
                      forceSync: true,
                      onChanged: cubit.regFlatChanged,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _Input62 extends StatefulWidget {
  final String hint;
  final String initialValue;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final double radius;
  final bool forceSync;

  const _Input62({required this.hint, this.initialValue = '', this.onChanged, this.forceSync = false, this.keyboardType, this.radius = 24});

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
  }

  @override
  void didUpdateWidget(covariant _Input62 oldWidget) {
    super.didUpdateWidget(oldWidget);

    final canUpdate = widget.forceSync || !_focusNode.hasFocus;

    if (canUpdate && oldWidget.initialValue != widget.initialValue && _controller.text != widget.initialValue) {
      _controller.value = _controller.value.copyWith(
        text: widget.initialValue,
        selection: TextSelection.collapsed(offset: widget.initialValue.length),
        composing: TextRange.empty,
      );
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
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(widget.radius)),
        ),
      ),
    );
  }
}

class _GreenSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _GreenSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 64,
        height: 34,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: value ? AppColors.primary : const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(24)),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 160),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class _SuggestionsBox<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T) titleOf;
  final ValueChanged<T> onTap;

  const _SuggestionsBox({required this.items, required this.titleOf, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 220),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: items.length.clamp(0, 8),
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) => ListTile(dense: true, title: Text(titleOf(items[i])), onTap: () => onTap(items[i])),
        ),
      ),
    );
  }
}
