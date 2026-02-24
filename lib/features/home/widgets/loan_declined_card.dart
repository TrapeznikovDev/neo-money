// declined_status_widget.dart
// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';

class DeclinedStatusWidget extends StatefulWidget {
  final OrderModel order;

  const DeclinedStatusWidget({
    super.key,
    required this.order,
  });

  @override
  State<DeclinedStatusWidget> createState() => _DeclinedStatusWidgetState();
}

class _DeclinedStatusWidgetState extends State<DeclinedStatusWidget> {


  String _parseAndFormatDifference(String dateString) {
    final format = DateFormat("dd.MM.yyyy HH:mm:ss");
    final DateTime parsedDate = format.parse(dateString);

    final now = DateTime.now();
    final Duration diff = parsedDate.difference(now);

    if (diff.isNegative) return "0 д. 0 ч. 0 мин.";

    final int days = diff.inDays;
    final int hours = diff.inHours % 24;
    final int minutes = diff.inMinutes % 60;

    return "$days д. $hours ч. $minutes мин.";
  }

  Future<void> _openPartner(String href) async {
    final uri = Uri.tryParse(href);
    if (uri == null) return;

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть ссылку')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    final partners = order.partners ?? const [];
    final hasPartners = partners.isNotEmpty;

    final availableDate = (order.availableDate ?? '').trim();
    final hasAvailableDate = availableDate.length > 3;

    int partnerIndex = 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.1,
                      ),
                      children: [
                        const TextSpan(text: 'К сожалению по вашей\nзаявке '),
                        TextSpan(
                          text: 'отказано',
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.error,
                            decoration: TextDecoration.underline,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child:Image.asset('assets/icons/wait_icon.png', width: 18, height: 18)
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Но вы можете получить деньги у наших партнеров',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 54,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasPartners
                    ? () async {
                  final href = partners[partnerIndex].href;
                  await _openPartner(href);
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Посмотреть одобренные\nпредложения',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          if (hasAvailableDate) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Или повторно обратиться за займом через:',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: Text(
                _parseAndFormatDifference(availableDate),
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}