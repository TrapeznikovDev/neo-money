import 'package:neomoney/features/cards/data/models/card_model.dart';

abstract class CardsRepository {
  Future<List<CardModel>> getCards();

  Future<String> getPaymentUrl();
}
