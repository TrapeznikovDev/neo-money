import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/features/documents/data/cubit/doc_cubit/doc_cubit.dart';
import 'package:neomoney/features/documents/data/cubit/doc_cubit/doc_state.dart';
import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';

class MinPaymentDocsDialog extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onConfirmed;

  const MinPaymentDocsDialog({
    super.key,
    required this.order,
    required this.onConfirmed,
  });

  @override
  State<MinPaymentDocsDialog> createState() => _MinPaymentDocsDialogState();
}

class _MinPaymentDocsDialogState extends State<MinPaymentDocsDialog> {
  bool _agree = false;

  @override
  void initState() {
    super.initState();
    // как в finhelp: сразу грузим документы
    context.read<DocCubit>().loadDocs('MIN_PAY_NEW');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BlocBuilder<DocCubit, DocState>(
          builder: (context, state) {
            final isLoading = state.status == UiStatus.loading;
            final isError = state.status == UiStatus.failure;

            // ВАЖНО: я не знаю точный тип doc-модели.
            // Ниже я обращаюсь как будто у doc есть поля `text` и `link`.
            // Если у тебя другой тип — поправь 2 места: doc.text / doc.link
            final docs = state.docs ?? const [];

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Минимальный платёж',
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Для продолжения подтвердите согласие с документами:',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (isLoading) ...[
                    const SizedBox(height: 8),
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 8),
                  ] else if (isError) ...[
                    Text(
                      state.errorMessage ?? 'Не удалось загрузить документы',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => context.read<DocCubit>().loadDocs('MIN_PAY_NEW'),
                        child: const Text('Повторить'),
                      ),
                    ),
                  ] else ...[
                    // список документов
                    if (docs.isEmpty)
                      Text(
                        'Документы не найдены',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      ...docs.map((doc) {
                        final String text = (doc as dynamic).text?.toString() ?? 'Документ';
                        final String? link = (doc as dynamic).link?.toString();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _DocRow(
                            text: text,
                            link: link,
                            onOpen: link == null || link.isEmpty
                                ? null
                                : () {
                              // TODO: открой свой PDF/WebView экран
                              // Navigator.of(context).pushNamed('/pdf', arguments: {'url': link});
                            },
                          ),
                        );
                      }),

                    const SizedBox(height: 4),

                    CheckboxListTile(
                      value: _agree,
                      onChanged: (v) => setState(() => _agree = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: RichText(
                        text: TextSpan(
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            const TextSpan(text: 'Я ознакомился и согласен(на) с условиями '),
                            TextSpan(
                              text: 'документов',
                              style: AppTypography.textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // опционально: показать общий список/экран документов
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Отказаться',
                            style: AppTypography.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (isLoading || isError) ? null : (_agree ? widget.onConfirmed : null),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Подтвердить',
                            style: AppTypography.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DocRow extends StatelessWidget {
  final String text;
  final String? link;
  final VoidCallback? onOpen;

  const _DocRow({
    required this.text,
    required this.link,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (onOpen != null) ...[
          const SizedBox(width: 8),
          InkWell(
            onTap: onOpen,
            child: Text(
              'Открыть',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ],
    );
  }
}