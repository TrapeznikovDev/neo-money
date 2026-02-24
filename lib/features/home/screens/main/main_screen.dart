import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/app/router.dart';
import 'package:neomoney/features/home/screens/fixation_selection_screen.dart';
import 'package:neomoney/features/home/screens/main/widgets/dialog_window.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:neomoney/app/di.dart';
import 'package:neomoney/core/presentation/base_bloc_page.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';

import 'package:neomoney/features/home/screens/main/data/cubit/orders_cubit.dart';
import 'package:neomoney/features/home/screens/main/data/cubit/orders_state.dart';
import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';

import 'package:neomoney/features/home/screens/main/widgets/all_expense_paid_button.dart';
import 'package:neomoney/features/home/screens/main/widgets/all_expense_paid_status.dart';
import 'package:neomoney/features/home/screens/main/widgets/bottom_banners_widget.dart';
import 'package:neomoney/features/home/screens/main/widgets/orders_list_container.dart';

class OrdersMainScreen extends BaseBlocPage<OrdersCubit, OrdersState> {
  const OrdersMainScreen({super.key});

  @override
  OrdersCubit createBloc(BuildContext context) => getIt<OrdersCubit>();

  @override
  bool get automaticallyImplyLeading => false;

  @override
  Widget buildBody(BuildContext context, OrdersState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<OrdersCubit>();

      cubit.init();
    });

    final orders = state.orders;
    final firstOrder = orders.isNotEmpty ? orders.first : null;

    final OrderModel? discountedOrder = orders.cast<OrderModel?>().firstWhere((o) => (o?.hasDiscount ?? false), orElse: () => null);

    return _OrdersMainContent(
      state: state,
      orders: orders,
      firstOrder: firstOrder,
      discountedOrder: discountedOrder,
      onOpenUrl: (url) => _openUrl(context, url),
      onRefresh: () => context.read<OrdersCubit>().refresh(),
    );
  }

  static Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось открыть ссылку')));
    }
  }
}

class _OrdersMainContent extends StatefulWidget {
  const _OrdersMainContent({
    required this.state,
    required this.orders,
    required this.firstOrder,
    required this.discountedOrder,
    required this.onOpenUrl,
    required this.onRefresh,
  });

  final OrdersState state;
  final List<OrderModel> orders;
  final OrderModel? firstOrder;
  final OrderModel? discountedOrder;
  final Future<void> Function(String url) onOpenUrl;
  final Future<void> Function() onRefresh;

  @override
  State<_OrdersMainContent> createState() => _OrdersMainContentState();
}

class _OrdersMainContentState extends State<_OrdersMainContent> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final orders = widget.orders;
    final firstOrder = widget.firstOrder;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.status == UiStatus.loading && orders.isNotEmpty)
                const Padding(padding: EdgeInsets.only(top: 6), child: LinearProgressIndicator(minHeight: 2)),

              const SizedBox(height: 10),

              Text(
                '${state.user?.lastname ?? ''} ${state.user?.firstname ?? ''} ${state.user?.patronymic ?? ''}'.trim(),
                style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 16),

              if (widget.discountedOrder != null) ...[_DiscountStubCard(order: widget.discountedOrder!), const SizedBox(height: 12)],

              OrdersListContainer(
                scrollController: _scrollController,
                onOrderTap: (order) {
                  // TODO
                },
              ),

              const SizedBox(height: 16),

              if (orders.isNotEmpty) ...[
                AllExpensePaidButton(
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouteNames.payment);
                  },
                ),
                const SizedBox(height: 12),
              ],

              if (orders.isNotEmpty)
                ...orders
                    .where((o) => (o.receiptStatus ?? '').isNotEmpty)
                    .map(
                      (o) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AllExpensePaidStatus(receiptStatus: o.receiptStatus!, receiptText: o.receiptHintText ?? ''),
                      ),
                    ),

              if (state.showBanner && (state.bannerLink?.isNotEmpty ?? false)) ...[
                _BannerStub(
                  imageUrl: state.bannerLink!,
                  onTap: () => widget.onOpenUrl(state.bannerLink!),
                ),
                const SizedBox(height: 16),
              ],

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final confirmed = await ConfirmLogoutDialog.show(
                      context,
                      title: 'Вы действительно хотите выйти?',
                    );

                    if (confirmed == true && context.mounted) {
                      await context.read<OrdersCubit>().logout();

                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRouteNames.splash,
                            (route) => false,
                      );
                    }
                  },
                  child: const Text('Выйти из профиля'),
                ),
              ),

              if (state.status == UiStatus.failure && (state.errorMessage?.isNotEmpty ?? false)) ...[
                const SizedBox(height: 12),
                Text(state.errorMessage!, style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.error)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscountStubCard extends StatelessWidget {
  const _DiscountStubCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final discount = (order.discountAmount ?? 0).toStringAsFixed(0);
    final today = (order.todayAmount ?? 0).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.buttonColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Вам доступна оплата со скидкой', style: AppTypography.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text('Остаток с учетом скидки', style: AppTypography.textTheme.bodySmall)),
              Text(
                '$discount ₽',
                style: AppTypography.textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text('$today ₽', style: AppTypography.textTheme.bodySmall?.copyWith(decoration: TextDecoration.lineThrough)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // TODO: открыть экран оплаты со скидкой
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Оплатить со скидкой $discount ₽'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerStub extends StatelessWidget {
  const _BannerStub({
    required this.imageUrl,
    required this.onTap,
  });

  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.secondary,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (_, __, ___) {
            // если вдруг ссылка битая — можно вообще ничего не показывать
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}