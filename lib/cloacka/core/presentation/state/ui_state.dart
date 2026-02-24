import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:neomoney/cloacka/features/home/model/planned_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Ключи prefs
const _kIncome = 'income';
const _kMonthlyPayments = 'monthly_payments';
const _kDailySpend = 'daily_spend';
const _kSavings = 'savings';
const _kPlannedPurchases = 'planned_purchases'; // список покупок

class AppState extends ChangeNotifier {
  final SharedPreferences _sp;

  AppState(this._sp) {
    _hydrate();
  }

  // =====================
  // State
  // =====================

  int _income = 0;
  int get income => _income;

  int _monthlyPayments = 0;
  int get monthlyPayments => _monthlyPayments;

  int _dailySpend = 0;
  int get dailySpend => _dailySpend;

  int _savings = 0;
  int get savings => _savings;

  PlannedPurchase? _selectedPurchase;
  PlannedPurchase? get selectedPurchase => _selectedPurchase;

  final List<PlannedPurchase> _plannedPurchases = [];
  List<PlannedPurchase> get plannedPurchases => List.unmodifiable(_plannedPurchases);

  // =====================
  // Hydrate / Persist
  // =====================

  void _hydrate() {
    _income = _sp.getInt(_kIncome) ?? 100000;
    _monthlyPayments = _sp.getInt(_kMonthlyPayments) ?? 30000;
    _dailySpend = _sp.getInt(_kDailySpend) ?? 800;
    _savings = _sp.getInt(_kSavings) ?? 30000;

    final raw = _sp.getString(_kPlannedPurchases);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = (jsonDecode(raw) as List)
            .whereType<Map<String, dynamic>>()
            .map(PlannedPurchase.fromJson)
            .toList();
        _plannedPurchases
          ..clear()
          ..addAll(list);
      } catch (_) {
        // если кривая сериализация — не падаем
      }
    }
  }

  Future<void> _persistPlannedPurchases() async {
    final raw = jsonEncode(_plannedPurchases.map((e) => e.toJson()).toList());
    await _sp.setString(_kPlannedPurchases, raw);
  }

  // =====================
  // Mutations
  // =====================

  Future<void> setIncome(int v) async {
    _income = v;
    await _sp.setInt(_kIncome, v);
    notifyListeners();
  }

  Future<void> setMonthlyPayments(int v) async {
    _monthlyPayments = v;
    await _sp.setInt(_kMonthlyPayments, v);
    notifyListeners();
  }

  Future<void> setDailySpend(int v) async {
    _dailySpend = v;
    await _sp.setInt(_kDailySpend, v);
    notifyListeners();
  }

  Future<void> setSavings(int v) async {
    _savings = v;
    await _sp.setInt(_kSavings, v);
    notifyListeners();
  }

  void selectPurchase(PlannedPurchase? p) {
    _selectedPurchase = p;
    notifyListeners();
  }

  Future<void> addPurchase(PlannedPurchase p) async {
    _plannedPurchases.add(p);
    await _persistPlannedPurchases();
    notifyListeners();
  }

  Future<void> removePurchase(PlannedPurchase p) async {
    _plannedPurchases.removeWhere((x) => x == p);
    if (_selectedPurchase == p) _selectedPurchase = null;
    await _persistPlannedPurchases();
    notifyListeners();
  }
}