import 'dart:convert';
import 'package:neomoney/cloacka/features/home/model/planned_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlannedPurchasesStorage {
  static const _kKey = 'planned_purchases_v1';

  final SharedPreferences _sp;
  PlannedPurchasesStorage(this._sp);

  List<PlannedPurchase> load() {
    final raw = _sp.getString(_kKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(PlannedPurchase.fromJson).toList();
    } catch (_) {
      // если формат сломался — не падаем
      return [];
    }
  }

  Future<void> save(List<PlannedPurchase> items) async {
    final json = jsonEncode(items.map((e) => e.toJson()).toList());
    await _sp.setString(_kKey, json);
  }

  Future<void> clear() => _sp.remove(_kKey);
}