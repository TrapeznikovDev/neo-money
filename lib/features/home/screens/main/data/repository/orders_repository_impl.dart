import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:neomoney/core/network/api_client.dart';
import 'package:neomoney/features/cards/data/models/card_model.dart';
import 'package:neomoney/features/documents/data/models/doc_model.dart';
import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';
import 'package:neomoney/features/home/screens/main/data/models/payment_item_model.dart';
import 'package:neomoney/features/home/screens/main/data/models/user_model.dart';
import 'package:neomoney/features/home/screens/main/data/repository/orders_repository.dart';

class OrdersRepositoryImpl implements OrderRepository {
  final ApiClient _api;

  OrdersRepositoryImpl(this._api);

  @override
  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await _api.get('v3/orders');

      if (response.statusCode == 200) {
        final ordersJson = response.data['data']['orders'] as List;
        final partnerJson = response.data['data'];
        debugPrint('Loaded ${ordersJson.length} orders');

        // Преобразуем каждый элемент массива (Map<String, dynamic>) в Order
        final orders = ordersJson.map((order) => OrderModel.fromJson(order, partnerJson)).toList();
        return orders;
      } else {
        throw Exception('Failed to load orders: StatusCode - ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> getUser() async {
    try {
      final response = await _api.get('user');

      if (response.statusCode == 200) {
        final data = response.data['data']['user'];

        return UserModel.fromJson(data);
      } else {
        throw Exception('Failed to load orders: StatusCode - ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CardModel>> getCards() async {
    try {
      final response = await _api.get('card_list');

      final data = response.data['data'] as List;
      return data.map((e) => CardModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> uploadReceipt(File file, int orderId) async {
    try {
      final formData = FormData.fromMap({
        'rs_file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        'order_id': orderId,
      });
      final response = await _api.post('v3/upload_receipt', data: formData);
      return response.data['success'];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendLoan(int amount, int term, int cardId, String cardType) async {
    try {
      final response = await _api.post(
        'send_loan',
        data: {
          'credit_doctor': false,
          'amount': amount,
          'period': term,
          'card_id': cardId,
          'service_insurance': false,
          if (cardType.isNotEmpty) 'card_type': cardType,
        },
      );
      return response.data['success'];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PaymentItemModel>> fetchPaymentSchedule(int orderId) async {
    final res = await _api.get('/v3/payment_schedule', queryParameters: {'order_id': orderId});
    final data = (res.data['data'] as List).cast<Map<String, dynamic>>();
    return data.map(PaymentItemModel.fromJson).toList();
  }

  @override
  Future<List<DocModel>> getDocs({String? type}) async {
    final path = (type != null && type.isNotEmpty) ? 'documents_order?type=$type' : 'documents_order';

    final response = await _api.get(path);

    if (response.statusCode != 200) {
      throw Exception('getDocs failed: ${response.statusCode}');
    }

    final data = response.data;

    if (data is! List) {
      throw Exception('getDocs: expected List, got ${data.runtimeType}');
    }

    return data.map((e) => DocModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<String> getPaymentUrl({
    required int? cardId,
    required double amount,
    required int? prolPeriod,
    required String orderNumber,
    String? smsCode,
    required String prolongation, // '1' / '0'
    bool? sendLoanAfterClosing,
    bool? multipolis,
    bool? tvMedical,
    required String type,
    String? action,
    int? chdp,
  }) async {
    final data = <String, dynamic>{
      if (cardId != null) 'card_id': cardId,
      'amount': amount,

      // лучше явно, как у тебя задумано
      'action_type': prolongation == '1' ? 'prolongation' : 'full_payment',
      'prolongation': prolongation,

      // type required => без if
      'type': type,

      if (smsCode != null) 'code_sms': smsCode,
      'number': orderNumber,

      // если бек реально ждёт '0'/'1' строкой — ок
      'multipolis': (multipolis ?? false) ? '1' : '0',
      'tv_medical': (tvMedical ?? false) ? '1' : '0',

      // если это всегда 1 — оставляем
      'additional_service': '1',

      if (prolPeriod != null) 'prolongation_period': prolPeriod,

      // если бек ждёт bool — оставляем bool
      'send_loan_after_closing': sendLoanAfterClosing ?? false,

      if (action != null) 'action': action,
      if (chdp != null) 'chdp': chdp,
    };

    final response = await _api.post('payment', data: data);

    if (response.statusCode != 200) {
      throw Exception('getPaymentUrl failed: ${response.statusCode}');
    }

    final body = response.data;

    // Иногда бэки присылают строку "Неверный код..." вместо JSON
    if (body is String) {
      if (body.contains('Неверный код')) {
        throw Exception(body); // чтобы наверху отобразить ошибку
      }
      throw Exception('Unexpected response: $body');
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response type: ${body.runtimeType}');
    }

    final dataNode = body['data'];

    if (dataNode is! Map<String, dynamic>) {
      throw Exception('Missing "data" in response');
    }

    // если action != null -> link, иначе payment_link (как у тебя)
    final key = action != null ? 'link' : 'payment_link';
    final url = dataNode[key];

    if (url is String && url.isNotEmpty) {
      return url;
    }

    throw Exception('Missing "$key" in response');
  }

  @override
  Future<String> refuseCoolingOrder(int orderId) async {
    final response = await _api.post('v3/refuse_cooling_order', data: {'order_id': orderId});
    if (response.statusCode == 200) {
      return (response.data['error'] ?? '').toString();
    }
    return 'Ошибка сервера';
  }

  @override
  Future<String> sendSms({required double amount, required int orderId}) async {
    final response = await _api.post(
      'v3/send_sms', // <-- подставь свой endpoint
      data: {
        'amount': amount,
        'order_id': orderId,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('sendSms failed: ${response.statusCode}');
    }

    final body = response.data;
    // пример: {"error":""} или {"success":true,"error":""}
    if (body is Map<String, dynamic>) {
      return (body['error'] ?? '').toString();
    }
    return '';
  }

  @override
  Future<String> checkSms({
    required int code,
    required int orderId,
    required int serviceInsurance,
    required int creditDoctor,
    required int acceptRecurrent,
    required int acceptContract,
    required int isStarOracle,
  }) async {
    final response = await _api.post(
      'checksms',
      data: {
        'code': code,
        'order_id': orderId,
        'service_insurance': serviceInsurance,
        'credit_doctor': creditDoctor,
        'accept_recurent': acceptRecurrent,
        'accept_contract': acceptContract,
        'is_star_oracle': isStarOracle,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('checkSms failed: ${response.statusCode}');
    }

    final body = response.data;
    if (body is Map<String, dynamic>) {
      return (body['error'] ?? '').toString();
    }
    return '';
  }

  @override
  Future<bool> update1s() async {
    final response = await _api.post('update_1s'); // <-- подставь свой endpoint
    if (response.statusCode != 200) return false;

    final body = response.data;
    if (body is Map<String, dynamic>) {
      final s = body['success'];
      if (s is bool) return s;
    }
    return true;
  }
}
