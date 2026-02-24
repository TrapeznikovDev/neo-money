import 'package:flutter/material.dart';
import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';

class BottomBannersWidget extends StatelessWidget {
  const BottomBannersWidget({
    super.key,
    required this.order,
    required this.onOpenUrl,
    required this.onOpenWebView,
  });

  final OrderModel order;
  final ValueChanged<String> onOpenUrl;
  final ValueChanged<String> onOpenWebView;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    final creditUrl = order.creditUrl;
    final fdChatLink = order.fdChatLink;

    if ((creditUrl ?? '').isNotEmpty && (fdChatLink ?? '').isEmpty) {
      items.add(_BannerStub(
        path: 'assets/images/credit_doctor.png',
        onTap: () => onOpenUrl(creditUrl!),
      ));
    }

    // 2) Finance doctor
    if ((fdChatLink ?? '').isNotEmpty) {
      items.add(_BannerStub(
        path: 'assets/images/finance_doctor.png',
        onTap: () => onOpenWebView(fdChatLink!),
      ));
    }

    // 3) VitaMed
    final showVita =
    ((order.isVitaMedPaid == null &&
        order.additionalService == true &&
        order.isActiveZaem == true) ||
        order.isVitaMedPaid == true);

    if (showVita) {
      items.add(_BannerStub(
        path: 'assets/images/vita_med.png',
        onTap: () => onOpenUrl('https://t.me/CashbackMedik_bot'),
      ));
    }

    // 4) Concierge / multipolis
    final showConcierge =
    ((order.isMultipolisPaid == null &&
        order.additionalService == true &&
        order.isActiveZaem == true) ||
        order.isMultipolisPaid == true);

    if (showConcierge) {
      items.add(_BannerStub(
        path: 'assets/images/concierge_service.png',
        onTap: () => onOpenUrl('https://t.me/BoostraCons_bot'),
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 12),
        ..._withSpacing(items, const SizedBox(height: 12)),
      ],
    );
  }

  List<Widget> _withSpacing(List<Widget> widgets, Widget gap) {
    final out = <Widget>[];
    for (var i = 0; i < widgets.length; i++) {
      out.add(widgets[i]);
      if (i != widgets.length - 1) out.add(gap);
    }
    return out;
  }
}

class _BannerStub extends StatelessWidget {
  const _BannerStub({
    required this.path,
    required this.onTap,
  });

  final String path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Image.asset(path)
      ),
    );
  }
}