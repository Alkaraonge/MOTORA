import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motora/motora_app.dart';
import 'package:motora/theme/motora_theme.dart';

void main() {
  test('يوفر عشرة ثيمات عربية بخطوط كاملة ومتنوعة', () {
    expect(motoraThemes, hasLength(10));
    expect(motoraThemes.map((theme) => theme.name).toSet(), hasLength(10));
    expect(
      motoraThemes.map((theme) => theme.fontFamily).toSet(),
      hasLength(10),
    );
    for (final theme in motoraThemes) {
      expect(theme.theme.textTheme.bodyMedium?.fontFamily, theme.fontFamily);
      expect(theme.theme.extension<MotoraTokens>(), isNotNull);
    }
  });

  testWidgets('يعرض هوية زيد الجديدة ويبدّل المظهر', (tester) async {
    await tester.pumpWidget(const MotoraApp());
    await tester.pumpAndSettle();

    expect(find.text('إدارة معرضك\nتبدأ من هنا'), findsOneWidget);
    expect(find.text('زيد للسيارات'), findsOneWidget);
    expect(find.text('بيع سيارة'), findsOneWidget);

    await tester.tap(find.byKey(const Key('theme-picker-button')));
    await tester.pumpAndSettle();
    expect(find.text('اختر مظهر التطبيق'), findsOneWidget);
    expect(find.text('الرمال'), findsOneWidget);

    await tester.tap(find.byKey(const Key('theme-option-1')));
    await tester.pumpAndSettle();
    expect(motoraThemes[1].fontFamily, 'Tajawal');
  });

  testWidgets('يفتح البيع والشراء والديون والعقود', (tester) async {
    await tester.pumpWidget(const MotoraApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('الحسابات'));
    await tester.pumpAndSettle();
    expect(find.text('الحسابات والعمليات'), findsOneWidget);
    expect(find.text('المبيعات'), findsOneWidget);
    expect(find.text('المشتريات'), findsOneWidget);
    expect(find.text('الديون'), findsOneWidget);
    expect(find.text('العقود'), findsOneWidget);

    await tester.tap(find.text('الديون'));
    await tester.pumpAndSettle();
    expect(find.text('الديون المتبقية'), findsOneWidget);
    expect(find.text('إضافة دين أو دفعة'), findsOneWidget);
  });

  testWidgets('لا تتجاوز الواجهة شاشة سامسونگ صغيرة مع تكبير النص', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 1.25;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(const MotoraApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
