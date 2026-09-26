import 'package:daway_app/features/pharmacy/presentation/widgets/product_action_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';

void main() {
  Future<void> pumpCard(WidgetTester tester, {VoidCallback? onTap}) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 192,
              child: ProductActionCard(label: 'أضف منتج جديد', onTap: onTap ?? () {}),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('is 56 tall and takes the width it is given', (tester) async {
    await pumpCard(tester);

    expect(tester.getSize(find.byType(ProductActionCard)), const Size(192, 56));
  });

  testWidgets('shows its label with a plus to the left of it, both centered', (tester) async {
    await pumpCard(tester);

    final card = tester.getRect(find.byType(ProductActionCard));
    final label = tester.getRect(find.text('أضف منتج جديد'));
    final plus = tester.getRect(find.byIcon(Icons.add));

    expect(plus.right, lessThanOrEqualTo(label.left));
    expect(plus.width, 24);
    // The pair, plus and label together, sits in the middle of the card.
    expect((plus.left + label.right) / 2, closeTo(card.center.dx, 0.5));
    expect(plus.center.dy, closeTo(card.center.dy, 0.5));
  });

  testWidgets('tapping it calls back', (tester) async {
    var taps = 0;
    await pumpCard(tester, onTap: () => taps++);

    await tester.tap(find.byType(ProductActionCard));

    expect(taps, 1);
  });

  testWidgets('a long label is cut off rather than overflowing', (tester) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 100,
              child: ProductActionCard(label: 'تحديث المنتجات بشكل كامل ودفعة واحدة', onTap: _noop),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

void _noop() {}
