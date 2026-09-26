import 'package:daway_app/core/theming/app_colors.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/presentation/widgets/product_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';

void main() {
  Future<void> pumpBadge(WidgetTester tester, MedicineStatus status) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: Scaffold(body: Center(child: ProductStatusBadge(status: status))),
      ),
    );
  }

  Color tintOf(WidgetTester tester) {
    final container = tester.widget<Container>(
      find.descendant(of: find.byType(ProductStatusBadge), matching: find.byType(Container)),
    );
    return (container.decoration! as BoxDecoration).color!;
  }

  testWidgets('available says متوفر, in green on a pale green', (tester) async {
    await pumpBadge(tester, MedicineStatus.available);

    expect(find.text('متوفر'), findsOneWidget);
    expect(tester.widget<Text>(find.text('متوفر')).style!.color, AppColors.productAvailableText);
    expect(tintOf(tester), AppColors.productAvailableTint);
  });

  testWidgets('low says مخزون منخفض, in orange on a pale orange', (tester) async {
    await pumpBadge(tester, MedicineStatus.low);

    expect(find.text('مخزون منخفض'), findsOneWidget);
    expect(tester.widget<Text>(find.text('مخزون منخفض')).style!.color, AppColors.statLowStock);
    expect(tintOf(tester), AppColors.productLowStockTint);
  });

  testWidgets('out of stock says نافد, in red on a pale red', (tester) async {
    await pumpBadge(tester, MedicineStatus.outOfStock);

    expect(find.text('نافد'), findsOneWidget);
    expect(tester.widget<Text>(find.text('نافد')).style!.color, AppColors.statOutOfStock);
    expect(tintOf(tester), AppColors.productOutOfStockTint);
  });

  testWidgets('is 21 tall', (tester) async {
    await pumpBadge(tester, MedicineStatus.available);

    expect(tester.getSize(find.byType(ProductStatusBadge)).height, closeTo(21, 0.5));
  });
}
