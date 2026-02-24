import 'package:flutter/material.dart';
import 'package:neomoney/cloacka/app/router/app_routes.dart';
import 'package:neomoney/cloacka/core/presentation/state/ui_state.dart';
import 'package:neomoney/cloacka/features/home/model/planned_purchase.dart';
import 'package:neomoney/cloacka/features/policy/widget/privacy_policy_widget.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:provider/provider.dart';

class PlannedPurchasesScreen extends StatefulWidget {
  const PlannedPurchasesScreen({super.key});

  @override
  State<PlannedPurchasesScreen> createState() => _PlannedPurchasesScreenState();
}

class _PlannedPurchasesScreenState extends State<PlannedPurchasesScreen> {
  final List<String> _items = ['Телевизор', 'Автомобиль'];

  void _deleteAt(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<void> _openAdd() async {
    final result = await Navigator.of(context).pushNamed(AppRoutesCloacka.plannedPurchaseAdd);
    if (result is PlannedPurchase) {
      await context.read<AppState>().addPurchase(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.plannedPurchases;
    return Scaffold(
      backgroundColor: AppColors.backColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          children: [
            Text(
              'Запланированные\nпокупки',
              style: AppTypography.textTheme.displayMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w700
              ),
            ),
            const SizedBox(height: 18),

            _CounterCard(count: items.length),

            const SizedBox(height: 18),

            ...items.map((p) => _SwipeToDeleteItem(
              key: ValueKey(p.hashCode),
              title: p.title,
              onTap: () => context.read<AppState>().selectPurchase(p),
              onDelete: () => context.read<AppState>().removePurchase(p),
            )),

            const SizedBox(height: 8),

            _AddButton(onTap: _openAdd),

            const SizedBox(height: 28),

            const PrivacyPolicyWidget(),
          ],
        ),
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  final int count;
  const _CounterCard({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Запланированные\nпокупки',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14
              ),
            ),
          ),
          Text(
            '$count',
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 24
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeToDeleteItem extends StatelessWidget {
  final String title;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _SwipeToDeleteItem({
    super.key,
    required this.title,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key!,
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFF4D4D),
          borderRadius: BorderRadius.circular(22),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric( vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.greyBackground,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            title,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF6FF),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Новая запланированная покупка',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.add, color: AppColors.primary, size: 28),
          ],
        ),
      ),
    );
  }
}