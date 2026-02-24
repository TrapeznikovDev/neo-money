import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/app/di.dart';
import 'package:neomoney/core/presentation/base_bloc_page.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/cards/data/cubit/cards_cubit.dart';
import 'package:neomoney/features/cards/data/cubit/cards_state.dart';
import 'package:neomoney/features/cards/widgets/card_tile.dart';

class CardsScreen extends BaseBlocPage<CardsCubit, CardsState> {
  const CardsScreen({super.key});

  @override
  CardsCubit createBloc(BuildContext context) {
    final cubit = getIt<CardsCubit>();
    Future.microtask(cubit.load);
    return cubit;
  }

  @override
  Widget buildBody(BuildContext context, CardsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(),

        Expanded(
          child: _buildContent(context, state),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, CardsState state) {
    if (state.status == UiStatus.loading && state.cards.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == UiStatus.failure && state.cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.errorMessage ?? 'Ошибка'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<CardsCubit>().load(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (state.status == UiStatus.success && state.cards.isEmpty) {
      return Column(
        children: [
          Container(
            height: 166,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEFF7FF),
                  Color(0xFFDDEEFF),
                ],
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Список карт пуст',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                Text(
                  'Необходимо добавить\nбанковскую карту',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.4),
          SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final cubit = context.read<CardsCubit>();
                  final url = await cubit.getPaymentUrl();
                  if (url == null || url.isEmpty) return;
                  if (!context.mounted) return;
                  await cubit.openUrl(context, url);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text(
                  'Добавить карту',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<CardsCubit>().refresh(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: state.cards.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index < state.cards.length) {
            return CardTile(model: state.cards[index]);
          }

          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final cubit = context.read<CardsCubit>();
                  final url = await cubit.getPaymentUrl();
                  if (url == null || url.isEmpty) return;
                  if (!context.mounted) return;
                  await cubit.openUrl(context, url);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text(
                  'Добавить карту',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 40),
      child: Text(
        'Карты',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
