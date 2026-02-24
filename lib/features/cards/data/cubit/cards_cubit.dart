import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/cards/data/cubit/cards_state.dart';
import 'package:neomoney/features/cards/data/models/card_model.dart';
import 'package:neomoney/features/cards/data/repository/cards_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class CardsCubit extends Cubit<CardsState> {
  final CardsRepository _repo;

  static const bool _useMock = false;

  CardsCubit(this._repo) : super(const CardsState());

  Future<void> load() async {
    emit(state.copyWith(status: UiStatus.loading, errorMessage: null));

    try {
      final cards = _useMock ? _mockCards() : await _repo.getCards();
      emit(state.copyWith(status: UiStatus.success, cards: cards));
    } catch (e) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<String?> getPaymentUrl() async {
    try {
      return await _repo.getPaymentUrl();
    } catch (e) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: e.toString()));
      return null;
    }
  }

  Future<void> refresh() => load();

  List<CardModel> _mockCards() => [
    CardModel(
      id: 1,
      cardNumber: '4111111111111111',
      // Visa (4000-4999)
      autoDebiting: 0,
      type: 'card',
      organizationId: 1,
    ),
    CardModel(
      id: 2,
      cardNumber: '5555555555554444',
      // MasterCard (5100-5599)
      autoDebiting: 0,
      type: 'card',
      organizationId: 1,
    ),
    CardModel(
      id: 3,
      cardNumber: '2200123412341234',
      // Мир (2200-2204)
      autoDebiting: 1,
      type: 'card',
      organizationId: 1,
    ),
  ];

  Future<void> openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Некорректная ссылка')),
      );
      return;
    }

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть ссылку')),
      );
    }
  }
}
