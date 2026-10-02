import 'package:daway_app/core/theming/app_colors.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/presentation/widgets/product_filter_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';

void main() {
  Future<void> pumpChips(
    WidgetTester tester, {
    int totalCount = 120,
    MedicineStatusFilter selected = MedicineStatusFilter.all,
    ValueChanged<MedicineStatusFilter>? onSelected,
  }) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ProductFilterChips(
              totalCount: totalCount,
              selected: selected,
              onSelected: onSelected ?? (_) {},
            ),
          ),
        ),
      ),
    );
  }

  /// The fill of the chip that holds [label].
  Color fillOf(WidgetTester tester, String label) {
    final container = tester.widget<Container>(
      find.ancestor(of: find.text(label), matching: find.byType(Container)).first,
    );
    return (container.decoration! as BoxDecoration).color!;
  }

  testWidgets('has the four chips, الكل first at the right, with the count on it', (tester) async {
    await pumpChips(tester);

    const labels = ['الكل(120)', 'متوفر', 'مخزون منخفض', 'نافد'];
    for (final label in labels) {
      expect(find.text(label), findsOneWidget);
    }
    final xs = [for (final label in labels) tester.getCenter(find.text(label)).dx];
    expect(xs, orderedEquals([...xs]..sort((a, b) => b.compareTo(a))));
  });

  testWidgets('the count follows the total', (tester) async {
    await pumpChips(tester, totalCount: 7);

    expect(find.text('الكل(7)'), findsOneWidget);
  });

  testWidgets('the chips are 33.1 tall, 8 apart, and as wide as their labels need', (tester) async {
    await pumpChips(tester);

    final all = tester.getRect(find.ancestor(of: find.text('الكل(120)'), matching: find.byType(Container)).first);
    final available = tester.getRect(find.ancestor(of: find.text('متوفر'), matching: find.byType(Container)).first);

    expect(all.height, closeTo(33.1, 0.01));
    expect(available.height, closeTo(33.1, 0.01));
    expect(all.left - available.right, closeTo(8, 0.01));
    // Padding 16 either side of the label.
    expect(all.width - tester.getSize(find.text('الكل(120)')).width, closeTo(32 + 2, 0.5));
  });

  testWidgets('a chip grows with an enlarged text instead of overflowing', (tester) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ProductFilterChips(
                totalCount: 120,
                selected: MedicineStatusFilter.all,
                onSelected: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    final chip = tester.getRect(find.ancestor(of: find.text('متوفر'), matching: find.byType(Container)).first);
    expect(tester.takeException(), isNull);
    expect(chip.height, greaterThan(33.1));
    expect(chip.height, greaterThanOrEqualTo(tester.getSize(find.text('متوفر')).height));
  });

  testWidgets('only the selected chip is solid blue', (tester) async {
    await pumpChips(tester, selected: MedicineStatusFilter.low);

    expect(fillOf(tester, 'مخزون منخفض'), AppColors.mainTeal);
    expect(fillOf(tester, 'الكل(120)'), AppColors.permissionIconBg);
    expect(fillOf(tester, 'متوفر'), AppColors.permissionIconBg);
    expect(fillOf(tester, 'نافد'), AppColors.permissionIconBg);
  });

  testWidgets('the selected label is Bold white, the others Medium blue', (tester) async {
    await pumpChips(tester);

    final selected = tester.widget<Text>(find.text('الكل(120)')).style!;
    final other = tester.widget<Text>(find.text('متوفر')).style!;
    expect(selected.color, Colors.white);
    expect(selected.fontWeight, FontWeight.w700);
    expect(other.color, AppColors.mainTeal);
    expect(other.fontWeight, FontWeight.w500);
  });

  testWidgets('tapping a chip reports its filter', (tester) async {
    final tapped = <MedicineStatusFilter>[];
    await pumpChips(tester, onSelected: tapped.add);

    // The test font is wider than Tajawal, so the last chips can be scrolled
    // out of sight.
    for (final label in ['متوفر', 'مخزون منخفض', 'نافد', 'الكل(120)']) {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
    }

    expect(tapped, [
      MedicineStatusFilter.available,
      MedicineStatusFilter.low,
      MedicineStatusFilter.outOfStock,
      MedicineStatusFilter.all,
    ]);
  });

  testWidgets('each chip is a button for a screen reader, and the selected one says so', (
    tester,
  ) async {
    await pumpChips(tester, selected: MedicineStatusFilter.available);
    final semantics = tester.ensureSemantics();

    expect(
      tester.getSemantics(find.bySemanticsLabel('متوفر')),
      isSemantics(label: 'متوفر', isButton: true, isSelected: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('نافد')),
      isNot(isSemantics(isSelected: true)),
    );
    semantics.dispose();
  });

  testWidgets('scrolls sideways instead of overflowing when the chips do not fit', (tester) async {
    await setDesignViewport(tester);
    tester.view.physicalSize = const Size(240, 600);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: Scaffold(
          body: ProductFilterChips(
            totalCount: 120,
            selected: MedicineStatusFilter.all,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
