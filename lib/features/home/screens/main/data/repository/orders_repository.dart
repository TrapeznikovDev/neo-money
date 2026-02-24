import 'dart:io';

import 'package:neomoney/features/cards/data/models/card_model.dart';
import 'package:neomoney/features/documents/data/models/doc_model.dart';
import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';
import 'package:neomoney/features/home/screens/main/data/models/payment_item_model.dart';
import 'package:neomoney/features/home/screens/main/data/models/user_model.dart';

abstract interface class OrderRepository {
  Future<List<OrderModel>> getOrders();

  Future<UserModel> getUser();

  Future<List<CardModel>> getCards();

  Future<bool> uploadReceipt(File file, int orderId);

  Future<void> sendLoan(int amount, int term, int cardId, String cardType);

  Future<List<PaymentItemModel>> fetchPaymentSchedule(int orderId);

  Future<List<DocModel>> getDocs({String type});

  Future<String> getPaymentUrl({
    required int? cardId,
    required double amount,
    required int? prolPeriod,
    required String orderNumber,
    String? smsCode,
    required String prolongation,
    bool? sendLoanAfterClosing,
    bool? multipolis,
    bool? tvMedical,
    required String type,
    String? action,
    int? chdp,
  });

  Future<String> sendSms({required double amount, required int orderId});

  Future<String> checkSms({
    required int code,
    required int orderId,
    required int serviceInsurance,
    required int creditDoctor,
    required int acceptRecurrent,
    required int acceptContract,
    required int isStarOracle,
  });

  Future<String> refuseCoolingOrder(int orderId);

  Future<bool> update1s();
}
