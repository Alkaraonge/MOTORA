import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motora/motora_app.dart';
import 'package:motora/theme/motora_theme.dart';

void main() {
  test('يوفر عشرة ثيمات عربية متفردة', () {
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

  testWidgets('يعرض الواجهة العربية ويبدّل المظهر', (tester) async {
    await tester.pumpWidget(const MotoraApp());
    await tester.pumpAndSettle();

    expect(find.text('الطريق يبدأ\nمن هنا'), findsOneWidget);
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('الملكي'), findsOneWidget);

    await tester.tap(find.byKey(const Key('theme-picker-button')));
    await tester.pumpAndSettle();
    expect(find.text('اختر شخصيتك'), findsOneWidget);
    expect(find.text('الرمال'), findsOneWidget);

    await tester.tap(find.byKey(const Key('theme-option-1')));
    await tester.pumpAndSettle();
    expect(find.text('الرمال'), findsOneWidget);
  });

  testWidgets('ينتقل إلى شاشة السيارات', (tester) async {
    await tester.pumpWidget(const MotoraApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('السيارات'));
    await tester.pumpAndSettle();
    expect(find.text('مجموعة MOTORA'), findsOneWidget);
    expect(find.text('MOTORA ONE'), findsOneWidget);
  });
}
