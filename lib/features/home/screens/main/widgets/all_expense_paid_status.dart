import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';

class AllExpensePaidStatus extends StatefulWidget {
  const AllExpensePaidStatus({
    super.key,
    required this.receiptStatus,
    required this.receiptText,
  });

  final String receiptStatus;
  final String receiptText;

  @override
  State<AllExpensePaidStatus> createState() => _AllExpensePaidStatusState();
}

class _AllExpensePaidStatusState extends State<AllExpensePaidStatus>
    with TickerProviderStateMixin {
  late final bool isApproved =
      widget.receiptStatus.toLowerCase() == 'approved';

  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final title = isApproved ? 'Платеж успешно принят.' : 'Платеж не подтвержден.';
    final color = isApproved ? const Color(0xFF1E8E3E) : const Color(0xFFC62828);
    final bg = isApproved ? const Color(0xFFE9F7EF) : const Color(0xFFFFEBEE);
    final icon = isApproved ? Icons.check : CupertinoIcons.xmark;

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: widget.receiptText.isNotEmpty
          ? () => setState(() => isExpanded = !isExpanded)
          : null,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withOpacity(0.7)),
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.topCenter,
          curve: Curves.easeInOut,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  if (widget.receiptText.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        CupertinoIcons.right_chevron,
                        size: 22,
                        color: color,
                      ),
                    ),
                  ]
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 12),
                Text(
                  widget.receiptText,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary.withOpacity(0.85),
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}