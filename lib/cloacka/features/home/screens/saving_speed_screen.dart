import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:neomoney/cloacka/core/presentation/state/ui_state.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:provider/provider.dart';

class SavingsSpeedScreen extends StatefulWidget {
  const SavingsSpeedScreen({super.key});

  @override
  State<SavingsSpeedScreen> createState() => _SavingsSpeedScreenState();
}

class _SavingsSpeedScreenState extends State<SavingsSpeedScreen> {
  final _goalController = TextEditingController(text: '100000');
  final _incomeController = TextEditingController(text: '100000');
  final _mandatoryController = TextEditingController(text: '30000');
  final _otherController = TextEditingController(text: '70000');
  final _scrollCtrl = ScrollController();
  final _resultKey = GlobalKey();

  int _months = 1;
  int? _freePerMonth;
  int? _monthsNeeded;

  final _money = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);

  int _parse(String s) => int.tryParse(s.replaceAll(RegExp(r'\D'), '')) ?? 0;

  String _fmt(int v) => _money.format(v).replaceAll('\u00A0', ' ');

  Future<void> _calculate() async {
    final st = context.read<AppState>();

    final goal = _parse(_goalController.text);
    final income = _parse(_incomeController.text);
    final mandatory = _parse(_mandatoryController.text);
    final other = _parse(_otherController.text);

    final free = income - mandatory - other;
    final need = (goal - st.savings) < 0 ? 0 : (goal - st.savings);

    if (free <= 0) {
      setState(() {
        _freePerMonth = free;
        _monthsNeeded = null;
      });
      return;
    }

    final monthsNeeded = (need / free).ceil();

    await st.setIncome(income);

    setState(() {
      _freePerMonth = free;
      _monthsNeeded = monthsNeeded;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
      final ctx = _resultKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          alignment: 0.15,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final st = context.read<AppState>();
      final p = st.selectedPurchase;

      setState(() {
        if (p != null) {
          _goalController.text = p.cost.toString();
          _months = p.months;
        }
        _incomeController.text = st.income.toString();
        _mandatoryController.text = st.monthlyPayments.toString();
        _otherController.text = (st.dailySpend * 30).toString();
      });
    });
  }

  @override
  void dispose() {
    _goalController.dispose();
    _incomeController.dispose();
    _mandatoryController.dispose();
    _otherController.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backColor,
      body: SafeArea(
        child: ListView(
          controller: _scrollCtrl,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          children: [
            Text('Скорость накопления', style: AppTypography.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),

            _GroupCard(
              children: [
                _InputCard(label: 'Сумма накопления', controller: _goalController),
                const SizedBox(height: 14),
                _SelectableText(label: 'Время накопления', value: '$_months месяц', onTap: _pickMonths),
              ],
            ),

            const SizedBox(height: 18),

            _InputCard(label: 'Доход', controller: _incomeController, highlighted: true),

            const SizedBox(height: 12),

            _InputCard(label: 'Обязательные траты', controller: _mandatoryController),

            const SizedBox(height: 12),

            _InputCard(label: 'Прочие траты', controller: _otherController),

            const SizedBox(height: 24),

            SizedBox(
              height: 62,
              child: ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                ),
                child: const Text('Рассчитать', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ),

            if (_freePerMonth != null) ...[
              const SizedBox(height: 24),
              KeyedSubtree(
                key: _resultKey,
                child: _ResultBlock(free: _freePerMonth!, months: _monthsNeeded, fmt: _fmt),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickMonths() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        int temp = _months;
        return SizedBox(
          height: 320,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(width: 16),
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Отмена')),
                  const Spacer(),
                  TextButton(onPressed: () => Navigator.of(context).pop(temp), child: const Text('Готово')),
                  const SizedBox(width: 16),
                ],
              ),
              const Divider(height: 1),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 44,
                  scrollController: FixedExtentScrollController(initialItem: _months - 1),
                  onSelectedItemChanged: (i) => temp = i + 1,
                  children: List.generate(12, (i) => Center(child: Text('${i + 1}'))),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => _months = selected);
    }
  }
}

class _ResultBlock extends StatelessWidget {
  final int free;
  final int? months;
  final String Function(int) fmt;

  const _ResultBlock({required this.free, required this.months, required this.fmt});

  @override
  Widget build(BuildContext context) {
    if (free <= 0) {
      return _ResultCard(title: 'Копить невозможно', subtitle: 'Расходы превышают доход', color: Colors.red);
    }

    return _ResultCard(
      title: 'Свободно в месяц',
      subtitle: fmt(free),
      extra: months != null ? 'Цель будет достигнута за $months мес.' : null,
      color: Colors.green,
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? extra;
  final Color color;

  const _ResultCard({required this.title, required this.subtitle, this.extra, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTypography.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          if (extra != null) ...[const SizedBox(height: 6), Text(extra!, style: AppTypography.textTheme.bodyMedium)],
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final List<Widget> children;

  const _GroupCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(color: const Color(0xFFEAF6FF), borderRadius: BorderRadius.circular(22)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _InputCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool highlighted;

  const _InputCard({required this.label, required this.controller, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(color: highlighted ? Colors.white : const Color(0xFFF3F5F7), borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.textTheme.titleMedium?.copyWith(color: const Color(0xFF6E7485), fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              isDense: true,
              hintText: '0',
              border: InputBorder.none,
              hintStyle: AppTypography.textTheme.titleMedium?.copyWith(color: const Color(0xFF6E7485).withOpacity(0.6), fontWeight: FontWeight.w700),
            ),
            style: AppTypography.textTheme.headlineMedium?.copyWith(color: Colors.black, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _SelectableText extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _SelectableText({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.titleMedium?.copyWith(color: const Color(0xFF6E7485), fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Text(
            value,
            style: AppTypography.textTheme.headlineSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}
