import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent local database for the dealership.
///
/// Records intentionally use string maps so old APK fields can be migrated and
/// exported without losing unknown values. Every mutation is written before
/// listeners are notified.
class BusinessStore extends ChangeNotifier {
  static const _databaseKey = 'zaid_business_database_v37';
  static const _legacySalesKey = 'zaid_sales_v36';
  static const _legacyPurchasesKey = 'zaid_purchases_v36';
  static const _legacyDebtsKey = 'zaid_debts_v36';

  final List<Map<String, String>> vehicles = <Map<String, String>>[];
  final List<Map<String, String>> sales = <Map<String, String>>[];
  final List<Map<String, String>> purchases = <Map<String, String>>[];
  final List<Map<String, String>> debts = <Map<String, String>>[];
  final List<Map<String, String>> contracts = <Map<String, String>>[];
  final List<Map<String, String>> customers = <Map<String, String>>[];
  final List<Map<String, String>> suppliers = <Map<String, String>>[];
  final List<Map<String, String>> payments = <Map<String, String>>[];
  final List<Map<String, String>> expenses = <Map<String, String>>[];
  final List<Map<String, String>> cashEntries = <Map<String, String>>[];
  final List<Map<String, String>> tasks = <Map<String, String>>[];
  final List<Map<String, String>> employees = <Map<String, String>>[];
  final Map<String, String> settings = <String, String>{
    'showroomName': 'زيد للسيارات',
    'showroomPhone': '',
    'showroomAddress': '',
    'notifications': 'true',
    'appLock': 'false',
    'themeIndex': '0',
  };

  bool loaded = false;

  Map<String, List<Map<String, String>>> get _collections =>
      <String, List<Map<String, String>>>{
        'vehicles': vehicles,
        'sales': sales,
        'purchases': purchases,
        'debts': debts,
        'contracts': contracts,
        'customers': customers,
        'suppliers': suppliers,
        'payments': payments,
        'expenses': expenses,
        'cashEntries': cashEntries,
        'tasks': tasks,
        'employees': employees,
      };

  Future<void> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final database = preferences.getString(_databaseKey);
      if (database != null && database.isNotEmpty) {
        _restoreDecoded(jsonDecode(database) as Map<String, dynamic>);
      } else {
        _decodeLegacy(preferences.getString(_legacySalesKey), sales);
        _decodeLegacy(preferences.getString(_legacyPurchasesKey), purchases);
        _decodeLegacy(preferences.getString(_legacyDebtsKey), debts);
        if (sales.isNotEmpty || purchases.isNotEmpty || debts.isNotEmpty) {
          await _save();
        }
      }
    } on Object {
      // A damaged cache must not stop the application. The user can restore a
      // JSON backup from the settings screen.
    } finally {
      loaded = true;
      notifyListeners();
    }
  }

  List<Map<String, String>> collection(String name) {
    final result = _collections[name];
    if (result == null) throw ArgumentError.value(name, 'name');
    return result;
  }

  Future<void> add(String collectionName, Map<String, String> values) async {
    final record = <String, String>{
      ...values,
      'id': values['id']?.isNotEmpty == true ? values['id']! : _newId(),
      'createdAt': values['createdAt']?.isNotEmpty == true
          ? values['createdAt']!
          : DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    collection(collectionName).insert(0, record);
    await _afterBusinessMutation(collectionName, record);
  }

  Future<void> update(
    String collectionName,
    String id,
    Map<String, String> values,
  ) async {
    final records = collection(collectionName);
    final index = records.indexWhere((item) => item['id'] == id);
    if (index < 0) return;
    records[index] = <String, String>{
      ...records[index],
      ...values,
      'id': id,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await _saveAndNotify();
  }

  Future<void> remove(String collectionName, String id) async {
    collection(collectionName).removeWhere((item) => item['id'] == id);
    if (collectionName == 'debts') {
      payments.removeWhere((item) => item['debtId'] == id);
    }
    await _saveAndNotify();
  }

  Future<void> addSale(Map<String, String> values) => add('sales', values);
  Future<void> addPurchase(Map<String, String> values) =>
      add('purchases', values);
  Future<void> addDebt(Map<String, String> values) => add('debts', values);

  Future<void> addDebtPayment(
    String debtId,
    String amount, {
    String note = '',
  }) async {
    final debt = debts.where((item) => item['id'] == debtId).firstOrNull;
    if (debt == null) return;
    final value = parseAmount(amount);
    if (value <= 0) return;
    final total = parseAmount(debt['total']);
    final oldPaid = parseAmount(debt['paid']);
    final newPaid = (oldPaid + value).clamp(0, total == 0 ? 1 << 62 : total);
    debt['paid'] = newPaid.toString();
    debt['updatedAt'] = DateTime.now().toIso8601String();
    payments.insert(0, <String, String>{
      'id': _newId(),
      'debtId': debtId,
      'person': debt['person'] ?? '',
      'amount': value.toString(),
      'note': note,
      'date': DateTime.now().toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _saveAndNotify();
  }

  Future<void> updateSettings(Map<String, String> values) async {
    settings.addAll(values);
    await _saveAndNotify();
  }

  int get salesTotal =>
      sales.fold(0, (sum, item) => sum + parseAmount(item['price']));
  int get salesReceived =>
      sales.fold(0, (sum, item) => sum + parseAmount(item['received']));
  int get purchasesTotal =>
      purchases.fold(0, (sum, item) => sum + parseAmount(item['price']));
  int get expensesTotal =>
      expenses.fold(0, (sum, item) => sum + parseAmount(item['amount']));
  int get debtsRemaining => debts.fold(
    0,
    (sum, item) =>
        sum +
        (parseAmount(item['total']) - parseAmount(item['paid'])).clamp(
          0,
          1 << 62,
        ),
  );
  int get cashBalance {
    final manual = cashEntries.fold<int>(0, (sum, item) {
      final amount = parseAmount(item['amount']);
      return sum + (item['type'] == 'وارد' ? amount : -amount);
    });
    return salesReceived - purchasesTotal - expensesTotal + manual;
  }

  int get estimatedProfit => salesTotal - purchasesTotal - expensesTotal;

  String exportJson() =>
      const JsonEncoder.withIndent('  ').convert(<String, dynamic>{
        'format': 'zaid-cars-backup',
        'version': 37,
        'exportedAt': DateTime.now().toIso8601String(),
        'settings': settings,
        for (final entry in _collections.entries) entry.key: entry.value,
      });

  String exportCsv() {
    final rows = <List<String>>[
      <String>[
        'القسم',
        'الاسم/السيارة',
        'الطرف',
        'المبلغ',
        'المدفوع',
        'التاريخ',
      ],
      ...sales.map(
        (item) => <String>[
          'مبيعات',
          item['car'] ?? '',
          item['customer'] ?? '',
          item['price'] ?? '',
          item['received'] ?? '',
          item['date'] ?? '',
        ],
      ),
      ...purchases.map(
        (item) => <String>[
          'مشتريات',
          '${item['maker'] ?? ''} ${item['model'] ?? ''}'.trim(),
          item['supplier'] ?? '',
          item['price'] ?? '',
          '',
          item['date'] ?? '',
        ],
      ),
      ...debts.map(
        (item) => <String>[
          'ديون',
          item['person'] ?? '',
          item['type'] ?? '',
          item['total'] ?? '',
          item['paid'] ?? '',
          item['date'] ?? '',
        ],
      ),
      ...expenses.map(
        (item) => <String>[
          'مصاريف',
          item['title'] ?? '',
          item['category'] ?? '',
          item['amount'] ?? '',
          '',
          item['date'] ?? '',
        ],
      ),
    ];
    return '\ufeff${rows.map((row) => row.map(_csvCell).join(',')).join('\n')}';
  }

  Future<void> restoreJson(String raw) async {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    if (decoded['format'] != 'zaid-cars-backup') {
      throw const FormatException('ملف النسخة الاحتياطية غير معروف');
    }
    _restoreDecoded(decoded);
    await _saveAndNotify();
  }

  Future<void> clearAll() async {
    for (final list in _collections.values) {
      list.clear();
    }
    await _saveAndNotify();
  }

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
    return int.tryParse(buffer.toString()) ?? 0;
  }

  static String formatAmount(int amount) {
    final negative = amount < 0;
    final digits = amount.abs().toString();
    final result = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) result.write(',');
      result.write(digits[index]);
    }
    return '${negative ? '-' : ''}${result.toString()} د.ع';
  }

  Future<void> _afterBusinessMutation(
    String collectionName,
    Map<String, String> record,
  ) async {
    if (collectionName == 'sales') {
      _upsertParty(customers, record['customer'], record['phone']);
      final price = parseAmount(record['price']);
      final received = parseAmount(record['received']);
      if (price > received && (record['customer'] ?? '').isNotEmpty) {
        debts.insert(0, <String, String>{
          'id': _newId(),
          'type': 'عميل',
          'person': record['customer'] ?? '',
          'phone': record['phone'] ?? '',
          'total': price.toString(),
          'paid': received.toString(),
          'due': record['due'] ?? '',
          'notes': 'متبقي بيع ${record['car'] ?? ''}',
          'saleId': record['id'] ?? '',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
      final vehicleId = record['vehicleId'];
      final vehicle = vehicles
          .where((item) => item['id'] == vehicleId)
          .firstOrNull;
      if (vehicle != null) vehicle['status'] = 'مباعة';
    } else if (collectionName == 'purchases') {
      _upsertParty(suppliers, record['supplier'], record['phone']);
      vehicles.insert(0, <String, String>{
        'id': _newId(),
        'maker': record['maker'] ?? '',
        'model': record['model'] ?? '',
        'year': record['year'] ?? '',
        'color': record['color'] ?? '',
        'chassis': record['chassis'] ?? '',
        'engine': record['engine'] ?? '',
        'plate': record['plate'] ?? '',
        'purchasePrice': record['price'] ?? '',
        'salePrice': record['salePrice'] ?? '',
        'status': 'متاحة',
        'notes': record['notes'] ?? '',
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
    await _saveAndNotify();
  }

  void _upsertParty(
    List<Map<String, String>> target,
    String? name,
    String? phone,
  ) {
    if (name == null || name.trim().isEmpty) return;
    final existing = target
        .where((item) => item['name'] == name.trim())
        .firstOrNull;
    if (existing != null) {
      if ((phone ?? '').isNotEmpty) existing['phone'] = phone!;
      return;
    }
    target.insert(0, <String, String>{
      'id': _newId(),
      'name': name.trim(),
      'phone': phone ?? '',
      'notes': '',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  void _restoreDecoded(Map<String, dynamic> decoded) {
    for (final entry in _collections.entries) {
      entry.value.clear();
      final raw = decoded[entry.key];
      if (raw is List<dynamic>) {
        entry.value.addAll(
          raw.whereType<Map<dynamic, dynamic>>().map(
            (item) => item.map(
              (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
            ),
          ),
        );
      }
    }
    final rawSettings = decoded['settings'];
    if (rawSettings is Map<dynamic, dynamic>) {
      settings.addAll(
        rawSettings.map(
          (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
        ),
      );
    }
  }

  void _decodeLegacy(String? raw, List<Map<String, String>> target) {
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      target.addAll(
        decoded.whereType<Map<dynamic, dynamic>>().map(
          (item) => <String, String>{
            ...item.map(
              (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
            ),
            'id': _newId(),
          },
        ),
      );
    } on FormatException {
      // Ignore only the damaged legacy list and keep other data available.
    }
  }

  Future<void> _saveAndNotify() async {
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_databaseKey, exportJson());
  }

  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${identityHashCode(this)}';

  static String _csvCell(String value) =>
      '"${value.replaceAll('"', '""').replaceAll('\n', ' ')}"';
}
