import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:neomoney/cloacka/core/presentation/state/ui_state.dart';
import 'package:neomoney/cloacka/features/home/home.dart';
import 'package:neomoney/cloacka/features/home/model/planned_purchase.dart';
import 'package:neomoney/cloacka/features/policy/widget/privacy_policy_widget.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:provider/provider.dart';

class PlannedPurchaseAddScreen extends StatefulWidget {
  const PlannedPurchaseAddScreen({super.key});

  @override
  State<PlannedPurchaseAddScreen> createState() => _PlannedPurchaseAddScreenState();
}

class _PlannedPurchaseAddScreenState extends State<PlannedPurchaseAddScreen> {
  final _whatController = TextEditingController();
  final _costController = TextEditingController();
  final _savingsController = TextEditingController();
  late final TextEditingController _remainingController;

  int _months = 1;

  final _money = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);

  @override
  void initState() {
    super.initState();

    _remainingController = TextEditingController(text: _fmtMoney(0));

    void recalc() {
      final cost = _parseInt(_costController.text);
      final savings = _parseInt(_savingsController.text);
      final remaining = (cost - savings) < 0 ? 0 : (cost - savings);

      final nextText = _fmtMoney(remaining);
      if (_remainingController.text != nextText) {
        _remainingController.text = nextText;
      }
    }

    _costController.addListener(recalc);
    _savingsController.addListener(recalc);

    recalc();
  }

  @override
  void dispose() {
    _whatController.dispose();
    _costController.dispose();
    _savingsController.dispose();
    _remainingController.dispose();
    super.dispose();
  }

  int _parseInt(String s) {
    final digits = s.replaceAll(RegExp(r'\D'), '');
    return int.tryParse(digits) ?? 0;
  }

  String _fmtMoney(int v) => _money.format(v).replaceAll('\u00A0', ' ');

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
                  children: List.generate(12, (i) => Center(child: Text('${i + 1} ${_monthWord(i + 1)}'))),
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

  static String _monthWord(int n) {
    if (n % 10 == 1 && n % 100 != 11) return 'месяц';
    if ([2, 3, 4].contains(n % 10) && ![12, 13, 14].contains(n % 100)) return 'месяца';
    return 'месяцев';
  }

  void _addToPlan() {
    final title = _whatController.text.trim();
    if (title.isEmpty) return;

    final cost = _parseInt(_costController.text);
    final savings = _parseInt(_savingsController.text);

    final purchase = PlannedPurchase(title: title, months: _months, cost: cost, savings: savings);

    context.read<AppState>().addPurchase(purchase);
    Navigator.of(context).pop();
  }

  final _formKey = GlobalKey<FormState>();

  void _showError(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: HomeAppBar(),
        backgroundColor: AppColors.backColor,
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 16 + MediaQuery.of(context).padding.bottom + 20),
                  children: [
                    Text(
                      'Планирование покупки',
                      style: AppTypography.textTheme.displayMedium?.copyWith(color: Colors.black, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 20),
                    _TopInfoCard(
                      title: _whatController.text.isEmpty ? 'Покупка' : _whatController.text,
                      monthsText: '$_months ${_monthWord(_months)}',
                      onMonthsTap: _pickMonths,
                    ),

                    const SizedBox(height: 14),

                    _InputCard(
                      label: 'Что покупаем?',
                      controller: _whatController,
                      hint: 'Телевизор',
                      keyboardType: TextInputType.text,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Введите название покупки';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _InputCard(
                      label: 'Стоимость',
                      controller: _costController,
                      hint: '0',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        final n = _parseInt(v ?? '');
                        if (n <= 0) return 'Введите стоимость';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _InputCard(
                      label: 'Накопления',
                      controller: _savingsController,
                      hint: '0',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        final savings = _parseInt(v ?? '');
                        final cost = _parseInt(_costController.text);
                        if (savings < 0) return 'Некорректное значение';
                        if (cost > 0 && savings > cost) return 'Накопления не могут быть больше стоимости';
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    _ReadonlyValueCard(label: 'Остаток до покупки', controller: _remainingController, highlighted: true),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 62,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addToPlan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                          textStyle: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        child: const Text('Добавить покупку в план'),
                      ),
                    ),

                    const SizedBox(height: 24),

                    PrivacyPolicyWidget(whiteLabel: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopInfoCard extends StatelessWidget {
  final String title;
  final String monthsText;
  final VoidCallback onMonthsTap;

  const _TopInfoCard({required this.title, required this.monthsText, required this.onMonthsTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          Text(
            'Время накопления',
            style: AppTypography.textTheme.titleMedium?.copyWith(color: const Color(0xFF6E7485), fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),

          GestureDetector(
            onTap: onMonthsTap,
            child: Text(
              monthsText,
              style: AppTypography.textTheme.displayMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 24),
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(18)),
            child: Text(
              'Быстро',
              style: AppTypography.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final String? Function(String?)? validator;

  const _InputCard({
    required this.label,
    required this.controller,
    required this.hint,
    required this.keyboardType,
    this.inputFormatters = const [],
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 16, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F7),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              label,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
              border: InputBorder.none,
              errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: AppTypography.textTheme.titleLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadonlyValueCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool highlighted;

  const _ReadonlyValueCard({required this.label, required this.controller, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 16, 18, 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              label,
              style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: controller,
            readOnly: true,
            enabled: false,
            decoration: InputDecoration(isDense: true, border: InputBorder.none),
            style: AppTypography.textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
