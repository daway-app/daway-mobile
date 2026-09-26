import 'package:daway_app/features/pharmacy/domain/entities/pharmacy_order.dart';
import 'package:daway_app/features/pharmacy/presentation/widgets/pharmacy_order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';

void main() {
  // RTL like the real app — the card's layout is right-to-left, so it has to
  // be tested that way.
  Widget buildTestable(PharmacyOrder order, {VoidCallback? onViewTap}) {
    return buildArabicTestApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: PharmacyOrderCard(order: order, onViewTap: onViewTap ?? () {}),
        ),
      ),
    );
  }

  PharmacyOrder orderWith({
    String number = 'DW-1021',
    DateTime? createdAt,
    int items = 2,
    double total = 80,
    String area = 'غزة - النصر',
  }) {
    return PharmacyOrder(
      orderNumber: number,
      createdAt: createdAt ?? DateTime.now(),
      itemsCount: items,
      total: total,
      area: area,
    );
  }

  testWidgets('shows the number, the price and the destination', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestable(orderWith(number: 'DW-1022', total: 65)));

    expect(find.text('#DW-1022'), findsOneWidget);
    expect(find.text('65 ₪'), findsOneWidget);
    expect(find.text('غزة - النصر'), findsOneWidget);
  });

  testWidgets('sets the order number left-to-right so its # stays in front', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestable(orderWith()));

    expect(tester.widget<Text>(find.text('#DW-1021')).textDirection, TextDirection.ltr);
  });

  testWidgets('sets the price left-to-right so the number comes before the ₪', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestable(orderWith(total: 80)));

    expect(tester.widget<Text>(find.text('80 ₪')).textDirection, TextDirection.ltr);
  });

  testWidgets('shows a fractional price with two decimals', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestable(orderWith(total: 12.5)));

    expect(find.text('12.50 ₪'), findsOneWidget);
  });

  // The abbreviated minutes/hours ("منذ 5 د") are covered where they are made,
  // in smart_date_formatter_test.dart, against a pinned clock; a card cannot
  // pin one, so this uses a date that is never "today" or "yesterday".
  testWidgets('shows the date of an order that is not recent', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestable(orderWith(createdAt: DateTime(2020, 1, 15, 9, 30))));

    expect(find.text('15 يناير 2020، 9:30 ص'), findsOneWidget);
  });

  testWidgets('the item count agrees with its noun', (tester) async {
    await setDesignViewport(tester);

    for (final (count, label) in [(1, 'دواء واحد'), (2, 'دواءان'), (5, '5 أدوية'), (11, '11 دواء')]) {
      await tester.pumpWidget(buildTestable(orderWith(items: count)));
      expect(find.text(label), findsOneWidget, reason: '$count items');
    }
  });

  testWidgets('عرض الطلب calls back', (tester) async {
    await setDesignViewport(tester);
    var taps = 0;
    await tester.pumpWidget(buildTestable(orderWith(), onViewTap: () => taps++));

    await tester.tap(find.text('عرض الطلب'));

    expect(taps, 1);
  });

  testWidgets('a long destination is cut off instead of overflowing its cell', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(
      buildTestable(orderWith(area: 'غزة - حي الشجاعية - شارع صلاح الدين - بجوار مسجد التقوى')),
    );

    expect(tester.takeException(), isNull);
  });
}
