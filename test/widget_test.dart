import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:recovery_app/services/promo_dialog_service.dart';
import 'package:recovery_app/widgets/app_promotion_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Promotion rotation alternates between the two apps on each launch',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final first = await PromoDialogService.getNextPromoApp();
    expect(first.name, contains('My Prayers'));

    final second = await PromoDialogService.getNextPromoApp();
    expect(second.name, contains('UltraBlock'));

    final third = await PromoDialogService.getNextPromoApp();
    expect(third.name, contains('My Prayers'));
  });

  testWidgets('Promotion dialog renders app info, install and close actions',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppPromotionDialog(app: PromoDialogService.promotedApps.first),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Prayers - صلاتي وأذكاري'), findsOneWidget);
    expect(find.text('تثبيت التطبيق الآن مجاناً'), findsOneWidget);
    expect(find.text('لاحقاً'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(4));
  });
}
