import 'package:flutter/foundation.dart';
import 'package:neomoney/core/network/api_client.dart';

import 'promocode_repository.dart';

class PromoCodeRepositoryImpl implements PromoCodeRepository {
  final ApiClient _api;

  PromoCodeRepositoryImpl(this._api);

  @override
  Future<bool> applyPromoCode({required String promocode, required int orderId}) async {
    if (promocode.trim().isEmpty) {
      throw Exception('Промокод пустой');
    }
    if (orderId <= 0) {
      throw Exception('Некорректный orderId');
    }

    try {
      final response = await _api.post('promocode/apply', data: {'promocode': promocode.trim(), 'order_id': orderId});

      if (response.statusCode != 200) {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }

      final body = response.data;

      bool success = true;

      if (body is Map<String, dynamic>) {
        final s = body['success'];
        if (s is bool) success = s;

        final err = body['error'];
        if (err is String && err.isNotEmpty) {
          success = false;

          throw Exception(err);
        }
      }

      if (!success) {
        throw Exception('Промокод не применён');
      }

      return true;
    } catch (e, st) {
      debugPrint('applyPromoCode error: $e\n$st');

      rethrow;
    }
  }
}
