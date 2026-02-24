import 'package:flutter/material.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';

class LoanCalculatorCard extends StatefulWidget {
  final int min;
  final int max;
  final int initial;

  final ValueChanged<int> onAmountChanged;
  final VoidCallback onSubmit;
  final VoidCallback onRulesTap;

  const LoanCalculatorCard({
    super.key,
    required this.min,
    required this.max,
    required this.initial,
    required this.onAmountChanged,
    required this.onSubmit,
    required this.onRulesTap,
  });

  @override
  State<LoanCalculatorCard> createState() => _LoanCalculatorCardState();
}

class _LoanCalculatorCardState extends State<LoanCalculatorCard> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initial.clamp(widget.min, widget.max);
  }

  @override
  void didUpdateWidget(covariant LoanCalculatorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial) {
      _value = widget.initial.clamp(widget.min, widget.max);
    }
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

  @override
  Widget build(BuildContext context) {
    final amountText = _formatRub(_value);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: Column(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Выберите сумму', style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    '$amountText ₽',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: const Color(0xFFE9E9E9),
                  trackHeight: 5,
                  thumbColor: Colors.white,
                  overlayColor: AppColors.primary.withOpacity(0.12),
                ),
                child: Slider(
                  value: _value.toDouble(),
                  min: widget.min.toDouble(),
                  max: widget.max.toDouble(),
                  onChanged:(v) {
                    setState(() => _value = v.round());
                    widget.onAmountChanged(_value);
                  },
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(_formatRub(widget.min), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  const Spacer(),
                  Text(_formatRub(widget.max), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 4),
                  const Text('Получить заем'),
                  Text('$amountText ₽'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}