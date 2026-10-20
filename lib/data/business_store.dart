import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusinessStore extends ChangeNotifier {
  static const _salesKey = 'zaid_sales_v36';
  static const _purchasesKey = 'zaid_purchases_v36';
  static const _debtsKey = 'zaid_debts_v36';

  final List<Map<String, String>> sales = <Map<String, String>>[];
  final List<Map<String, String>> purchases = <Map<String, String>>[];
  final List<Map<String, String>> debts = <Map<String, String>>[];

  bool loaded = false;

  Future<void> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      _decodeInto(preferences.getString(_salesKey), sales);
      _decodeInto(preferences.getString(_purchasesKey), purchases);
      _decodeInto(preferences.getString(_debtsKey), debts);
    } on Object {
      // Widget tests and unsupported platforms can safely use the memory store.
    } finally {
      loaded = true;
      notifyListeners();
    }
  }

  Future<void> addSale(Map<String, String> record) async {
    sales.insert(0, Map<String, String>.unmodifiable(record));
    await _save(_salesKey, sales);
    notifyListeners();
  }

  Future<void> addPurchase(Map<String, String> record) async {
    purchases.insert(0, Map<String, String>.unmodifiable(record));
    await _save(_purchasesKey, purchases);
    notifyListeners();
  }

  Future<void> addDebt(Map<String, String> record) async {
    debts.insert(0, Map<String, String>.unmodifiable(record));
    await _save(_debtsKey, debts);
    notifyListeners();
  }

  int get salesTotal =>
      sales.fold(0, (sum, item) => sum + parseAmount(item['price']));
  int get purchasesTotal =>
      purchases.fold(0, (sum, item) => sum + parseAmount(item['price']));
  int get debtsRemaining => debts.fold(
    0,
    (sum, item) =>
        sum +
        (parseAmount(item['total']) - parseAmount(item['paid'])).clamp(
          0,
          1 << 62,
        ),
  );

  static int parseAmount(String? value) {
    if (value == null) return 0;
    const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
    const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
    final buffer = StringBuffer();
    for (final codePoint in value.runes) {
      final character = String.fromCharCode(codePoint);
      final arabicIndex = arabicDigits.indexOf(character);
      final persianIndex = persianDigits.indexOf(character);
      if (arabicIndex >= 0) {
        buffer.write(arabicIndex);
      } else if (persianIndex >= 0) {
        buffer.write(persianIndex);
      } else if (RegExp(r'[0-9]').hasMatch(character)) {
        buffer.write(character);
      }
    }
    final normalized = buffer.toString();
    return int.tryParse(normalized) ?? 0;
  }

  static String formatAmount(int amount) {
    final digits = amount.toString();
    final result = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) result.write(',');
      result.write(digits[index]);
    }
    return '${result.toString()} د.ع';
  }

  void _decodeInto(String? raw, List<Map<String, String>> target) {
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      target
        ..clear()
        ..addAll(
          decoded.map(
            (item) => Map<String, String>.from(item as Map<dynamic, dynamic>),
          ),
        );
    } on FormatException {
      // A damaged local cache must not prevent the application from starting.
    }
  }

  Future<void> _save(String key, List<Map<String, String>> values) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, jsonEncode(values));
  }
}
