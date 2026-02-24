import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:neomoney/app/di.dart';
import 'package:neomoney/cloacka/app/router/app_routes.dart';
import 'package:neomoney/cloacka/core/storage/app_prefs.dart';
import 'package:neomoney/core/auth/token_storage.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';

class MyFinancesScreen extends StatefulWidget {
  const MyFinancesScreen({super.key});

  @override
  State<MyFinancesScreen> createState() => _MyFinancesScreenState();
}

class _MyFinancesScreenState extends State<MyFinancesScreen> {
  DateTime _payDate = DateTime(2026, 2, 5);

  final _ru = DateFormat('d MMMM y', 'ru_RU');

  Future<void> _pickPayDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _payDate,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 10),
      locale: const Locale('ru', 'RU'),
      builder: (context, child) {
        // если у вас есть своя тема — позже подцепим
        return child!;
      },
    );

    if (selected != null) {
      setState(() => _payDate = selected);
    }
  }

  Future<void> _logout() async {
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text('Точно хотите выйти?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            isDefaultAction: true,
            child: const Text('Нет'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(true),
            isDestructiveAction: true,
            child: const Text('Да'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 1) чистим токен основного потока
    await getIt<TokenStorage>().clear();

    // 2) чистим признак авторизации клоаки
    await getIt<AppPrefs>().logout();

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutesCloacka.auth,
          (_) => false,
    );
  }

  String _fmtDate(DateTime d) => _ru.format(d);

  late final TextEditingController _savingsCtrl;
  late final TextEditingController _advanceCtrl;
  late final TextEditingController _monthlyCtrl;
  late final TextEditingController _dailyCtrl;
  late final TextEditingController _plannedCtrl;

  @override
  void initState() {
    super.initState();
    _advanceCtrl = TextEditingController();
    _savingsCtrl = TextEditingController();
    _monthlyCtrl = TextEditingController();
    _dailyCtrl = TextEditingController();
    _plannedCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _savingsCtrl.dispose();
    _monthlyCtrl.dispose();
    _dailyCtrl.dispose();
    _plannedCtrl.dispose();
    _advanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          children: [
            Text(
              'Мои финансы',
              style: AppTypography.textTheme.displayMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),

            _PayCard(
              dateText: _fmtDate(_payDate),
              controller: _advanceCtrl,
              onCalendarTap: _pickPayDate,
            ),

            const SizedBox(height: 18),

            _EditableValueCard(
              title: 'Накопления',
              controller: _savingsCtrl,
            ),
            const SizedBox(height: 12),

            _EditableValueCard(
              title: 'Ежемесячные платежи',
              controller: _monthlyCtrl,
            ),
            const SizedBox(height: 12),

            _EditableValueCard(
              title: 'Ежедневные траты',
              controller: _dailyCtrl,
            ),
            const SizedBox(height: 12),

            _EditableValueCard(
              title: 'Планируемые покупки',
              controller: _plannedCtrl,
              money: false,
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 70,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor:  AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Text(
                  'Выйти',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayCard extends StatelessWidget {
  final String dateText;
  final TextEditingController controller;
  final VoidCallback onCalendarTap;

  const _PayCard({
    required this.dateText,
    required this.controller,
    required this.onCalendarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Аванс / оплата',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF6E7485),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              InkResponse(
                onTap: onCalendarTap,
                radius: 28,
                child: Image.asset(
                  'assets/icons/calendar.png',
                  width: 38,
                  height: 38,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onCalendarTap,
            child: Text(
              dateText,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: AppTypography.textTheme.headlineMedium?.copyWith(
                color: Colors.black.withOpacity(0.3),
                fontWeight: FontWeight.w900,
              ),
              suffixText: ' ₽',
              suffixStyle: AppTypography.textTheme.headlineMedium?.copyWith(
                color: Colors.black.withOpacity(0.5),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableValueCard extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final bool money;

  const _EditableValueCard({
    required this.title,
    required this.controller,
    this.money = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F7),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF6E7485),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: AppTypography.textTheme.headlineMedium?.copyWith(
                color: Colors.black.withOpacity(0.3),
                fontWeight: FontWeight.w900,
              ),
              suffixText: ' ₽',
              suffixStyle: AppTypography.textTheme.headlineMedium?.copyWith(
                color: Colors.black.withOpacity(0.5),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}