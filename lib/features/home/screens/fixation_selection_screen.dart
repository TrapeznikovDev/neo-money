import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:neomoney/core/presentation/base_bloc_page.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/features/home/screens/main/bloc/fixation_bloc/payment_fixation_cubit.dart';
import 'package:neomoney/features/home/screens/main/bloc/fixation_bloc/payment_fixation_state.dart';
import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';

class FixationSelectionScreen extends BaseBlocPage<PaymentFixationCubit, PaymentFixationState> {
  final List<OrderModel> orders;

  const FixationSelectionScreen({super.key, required this.orders});

  @override
  PaymentFixationCubit createBloc(BuildContext context) {
    return GetIt.I.get<PaymentFixationCubit>();
  }

  @override
  String? get title => 'Фиксация оплаты';

  @override
  Widget buildBody(BuildContext context, PaymentFixationState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Обратите внимание!', style: AppTypography.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Фиксация оплаты — это уведомление о том, что вы произвели платеж.', style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          SizedBox(height: 5),
          Text('Платеж зачисляется на ваш счет в течение 3 рабочих дней, в зависимости от банка и способа перевода.', style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.buttonColor, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Text(
                  'Этот раздел предназначен только для фиксации оплаты, произведенной по банковским реквизитам в ручном режиме (например, через мобильное приложение или отделение банка).',
                  style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.primary),
                ),
                SizedBox(height: 20),
                Text(
                  'Пожалуйста, не загружайте сюда чеки от оплат, совершенных через Личный кабинет или по кнопке “Best2Pay” — такие платежи фиксируются автоматически и не требуют подтверждения.',
                  style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.primary),
                ),
                SizedBox(height: 20),
                Text(
                  'Также обращаем внимание:\n— Загружать чек необходимо только при оплате полной суммы задолженности.\n— Частные платежи в обработку не принимаются.',
                  style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Номер договора', style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          _buildDropdown<OrderModel?>(
            value: state.order,
            items: orders,
            itemLabel: (o) => o?.number ?? '',
            hint: 'Выберите договор',
            onChanged: (order) => context.read<PaymentFixationCubit>().setOrder(order!),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Text('Файл', style: AppTypography.textTheme.bodySmall)),
              Expanded(
                flex: 3,
                child: state.file != null
                    ? ListTile(
                        title: Text(
                          state.file!.path.split('/').last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: AppColors.primary),
                          onPressed: () => context.read<PaymentFixationCubit>().removeFile(),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: () => context.read<PaymentFixationCubit>().pickFile(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                        ),
                        child: const Text('Прикрепить файл'),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: state.file != null && state.order != null ? () => context.read<PaymentFixationCubit>().uploadReceipt() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required String Function(T?) itemLabel,
    required ValueChanged<T?> onChanged,
    String hint = '',
  }) {
    return DropdownButtonFormField<T?>(
      value: value,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      items: items.map((e) {
        return DropdownMenuItem<T?>(
          value: e,
          child: Text(itemLabel(e), style: AppTypography.textTheme.bodyMedium),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
