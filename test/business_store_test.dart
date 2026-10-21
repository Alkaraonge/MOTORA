import 'package:flutter_test/flutter_test.dart';
import 'package:motora/data/business_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('يحفظ المبيعات والمشتريات والديون محلياً', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = BusinessStore();
    await store.load();

    await store.addSale(<String, String>{'price': '٣٨,٥٠٠,٠٠٠'});
    await store.addPurchase(<String, String>{'price': '32000000'});
    await store.addDebt(<String, String>{
      'total': '٨,٠٠٠,٠٠٠',
      'paid': '٣,٠٠٠,٠٠٠',
    });

    expect(store.salesTotal, 38500000);
    expect(store.purchasesTotal, 32000000);
    expect(store.debtsRemaining, 5000000);

    final restored = BusinessStore();
    await restored.load();
    expect(restored.sales, hasLength(1));
    expect(restored.purchases, hasLength(1));
    expect(restored.debts, hasLength(1));
  });

  test('يربط الشراء بالمخزون والبيع بالدين والدفعات', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = BusinessStore();
    await store.load();

    await store.addPurchase(<String, String>{
      'maker': 'تويوتا',
      'model': 'كامري',
      'supplier': 'شركة الاختبار',
      'price': '30000000',
      'salePrice': '35000000',
    });
    expect(store.vehicles, hasLength(1));
    expect(store.suppliers.single['name'], 'شركة الاختبار');

    final vehicleId = store.vehicles.single['id']!;
    await store.addSale(<String, String>{
      'vehicleId': vehicleId,
      'car': 'تويوتا كامري',
      'customer': 'أحمد',
      'phone': '0700',
      'price': '35000000',
      'received': '10000000',
    });
    expect(store.vehicles.single['status'], 'مباعة');
    expect(store.customers.single['name'], 'أحمد');
    expect(store.debtsRemaining, 25000000);

    await store.addDebtPayment(store.debts.single['id']!, '5000000');
    expect(store.debtsRemaining, 20000000);
    expect(store.payments, hasLength(1));
  });

  test('يصدر نسخة احتياطية ويستعيد كل السجلات', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = BusinessStore();
    await store.load();
    await store.add('vehicles', <String, String>{
      'maker': 'كيا',
      'model': 'سبورتاج',
      'status': 'متاحة',
    });
    await store.add('contracts', <String, String>{
      'number': 'ZC-1',
      'buyerName': 'محمد',
    });
    final backup = store.exportJson();

    await store.clearAll();
    expect(store.vehicles, isEmpty);
    await store.restoreJson(backup);
    expect(store.vehicles.single['model'], 'سبورتاج');
    expect(store.contracts.single['number'], 'ZC-1');
  });
}
