import 'package:flutter/material.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';

class CurrentLoanCard extends StatelessWidget {
  final String loanNumber; // A24-2758246
  final int principalBalanceRub; // 1000
  final String plannedPaymentDate; // 24.04.2024

  final String minPaymentTitle; // "Минимальный\nплатеж"
  final int minPaymentRub; // 250

  final String primaryButtonText; // "Полное погашение\nи новая заявка"
  final VoidCallback onPrimaryPressed;

  final String linkText; // "Полное погашение"
  final VoidCallback onLinkPressed;

  const CurrentLoanCard({
    super.key,
    required this.loanNumber,
    required this.principalBalanceRub,
    required this.plannedPaymentDate,
    required this.minPaymentTitle,
    required this.minPaymentRub,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    required this.linkText,
    required this.onLinkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 32,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),

        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(loanNumber: loanNumber),
          const SizedBox(height: 14),

          _RowKV(
            label: 'Остаток основного долга',
            value: _formatRub(principalBalanceRub),
          ),
          const SizedBox(height: 10),
          _RowKV(
            label: 'Дата планового платежа',
            value: plannedPaymentDate,
          ),

          const SizedBox(height: 14),

          _MinPaymentPill(
            title: minPaymentTitle,
            value: _formatRub(minPaymentRub),
          ),

          const SizedBox(height: 14),

          SizedBox(
            height: 64,
            child: ElevatedButton(
              onPressed: onPrimaryPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                elevation: 0,
              ),
              child: Text(
                primaryButtonText,
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: InkWell(
              onTap: onLinkPressed,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  linkText,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatRub(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(' ');
    }
    return '${buf.toString()} ₽';
  }
}

class _Header extends StatelessWidget {
  final String loanNumber;

  const _Header({required this.loanNumber});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Текущий заем',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          loanNumber,
          style: AppTypography.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _RowKV extends StatelessWidget {
  final String label;
  final String value;

  const _RowKV({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _MinPaymentPill extends StatelessWidget {
  final String title;
  final String value;

  const _MinPaymentPill({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F3FF), // светло-голубой как на макете
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 20
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 20
            ),
          ),
        ],
      ),
    );
  }
}