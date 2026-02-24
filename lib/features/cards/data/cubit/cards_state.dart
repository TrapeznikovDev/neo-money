import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/cards/data/models/card_model.dart';

class CardsState implements UiState {
  @override
  final UiStatus status;

  @override
  final String? errorMessage;

  final List<CardModel> cards;

  const CardsState({
    this.status = UiStatus.initial,
    this.errorMessage,
    this.cards = const [],
  });

  CardsState copyWith({
    UiStatus? status,
    String? errorMessage,
    List<CardModel>? cards,
  }) {
    return CardsState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      cards: cards ?? this.cards,
    );
  }
}