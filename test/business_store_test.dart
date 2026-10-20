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
}
