import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/features/registration/cubit/registration_cubit.dart';

class StepPreApprove extends StatelessWidget {
  const StepPreApprove({super.key});

  static const int _min = 1000;
  static const int _max = 30000;

  static const int _termMin = 5;
  static const int _termMax = 16;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<RegistrationFlowCubit>().state;

    final amount = s.preapprovedAmount;
    final term = s.preapprovedTerm;

    final amountText = _formatRub(amount);

    final fullToPayText = s.fullAmountToBePaid == null
        ? '—'
        : '${_formatRub(s.fullAmountToBePaid!)}₽';

    final percentText = s.percent == null ? '—' : '${s.percent}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              // ---------- СУММА ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Выберите сумму'),
                  Text(
                    '$amountText ₽',
                    style: AppTypography.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _sliderTheme(context,
                child: Slider(
                  value: amount.toDouble().clamp(_min.toDouble(), _max.toDouble()),
                  min: _min.toDouble(),
                  max: _max.toDouble(),
                  divisions: ((_max - _min) ~/ 1000),
                  onChanged: (v) {
                    final rounded = ((v / 1000).round() * 1000).clamp(_min, _max);
                    context.read<RegistrationFlowCubit>().preapprovedAmountChanged(rounded);
                  },
                  onChangeEnd: (_) => context.read<RegistrationFlowCubit>().fetchLoanCalc(),
                ),
              ),

              const SizedBox(height: 6),
              Row(
                children: [
                  Text(_formatRub(_min),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      )),
                  const Spacer(),
                  Text(_formatRub(_max),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),

              const SizedBox(height: 14),

              // ---------- СРОК ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Выберите срок'),
                  Text(
                    '$term дней',
                    style: AppTypography.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _sliderTheme(context,
                child: Slider(
                  value: term.toDouble().clamp(_termMin.toDouble(), _termMax.toDouble()),
                  min: _termMin.toDouble(),
                  max: _termMax.toDouble(),
                  divisions: (_termMax - _termMin), // шаг 1 день
                  onChanged: (v) {
                    context.read<RegistrationFlowCubit>().preapprovedTermChanged(v.round());
                  },
                  onChangeEnd: (_) => context.read<RegistrationFlowCubit>().fetchLoanCalc(),
                ),
              ),

              const SizedBox(height: 6),
              Row(
                children: [
                  Text('$_termMin',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      )),
                  const Spacer(),
                  Text('$_termMax',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),

              const SizedBox(height: 16),

              // ---------- ВЫ ВЕРНЕТЕ / СТАВКА ----------
              if (s.calcError.isNotEmpty) ...[
                Text(
                  s.calcError,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              _InfoCard(
                leftTitle: 'Вы вернете',
                leftValue: s.calcLoading ? '...' : fullToPayText,
                rightTitle: 'Ставка',
                rightValue: s.calcLoading ? '...' : percentText,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sliderTheme(BuildContext context, {required Widget child}) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: const Color(0xFFE9E9E9),
        trackHeight: 5,
        thumbColor: Colors.white,
        overlayColor: AppColors.primary.withOpacity(0.12),
        tickMarkShape: SliderTickMarkShape.noTickMark,
        showValueIndicator: ShowValueIndicator.never,
      ),
      child: child,
    );
  }

  String _formatRub(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(' ');
    }
    return buf.toString();
  }
}

class _InfoCard extends StatelessWidget {
  final String leftTitle;
  final String leftValue;
  final String rightTitle;
  final String rightValue;

  const _InfoCard({required this.leftTitle, required this.leftValue, required this.rightTitle, required this.rightValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(
            child: _InfoCol(title: leftTitle, value: leftValue),
          ),
          Expanded(
            child: _InfoCol(title: rightTitle, value: rightValue),
          ),
        ],
      ),
    );
  }
}

class _InfoCol extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCol({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final t1 = TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary);
    final t2 = TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: t1),
        const SizedBox(height: 6),
        Text(value, style: t2),
      ],
    );
  }
}
