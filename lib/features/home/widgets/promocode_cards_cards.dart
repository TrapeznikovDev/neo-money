import 'package:flutter/material.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';

class PromoCodeCard extends StatelessWidget {
  final String code;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback onApply;

  const PromoCodeCard({
    super.key,
    required this.code,
    required this.isLoading,
    required this.onChanged,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: code);

    // важно: чтобы не сбивало курсор при rebuild — лучше вынести в Stateful,
    // но для каркаса ок. Если хочешь “идеально” — сделаю Stateful версию.
    controller.selection = TextSelection.collapsed(offset: controller.text.length);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              enabled: !isLoading,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Ввести промокод',
              ),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          TextButton(
            onPressed: isLoading ? null : onApply,
            child: Text(
              'Применить',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}