import 'package:neomoney/core/network/api_client.dart';
import 'package:neomoney/features/cards/data/models/card_model.dart';
import 'package:neomoney/features/cards/data/repository/cards_repository.dart';

class CardsRepositoryImpl implements CardsRepository {
  final ApiClient _api;

  CardsRepositoryImpl(this._api);

  @override
  Future<List<CardModel>> getCards() async {
    final response = await _api.get('card_list');

    final raw = response.data;
    final data = (raw is Map<String, dynamic>) ? raw['data'] : null;

    final list = (data is List) ? data : <dynamic>[];

    return list.whereType<Map<String, dynamic>>().map(CardModel.fromJson).toList();
  }

  @override
  Future<String> getPaymentUrl() async{
    final response = await _api.get('get_payment_url');

    final data = response.data['data']['link'];

    return data;
  }
}
