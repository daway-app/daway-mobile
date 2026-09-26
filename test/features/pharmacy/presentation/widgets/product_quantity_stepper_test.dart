import 'package:daway_app/features/pharmacy/presentation/widgets/product_quantity_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';

void main() {
  Future<void> pumpStepper(
    WidgetTester tester, {
    int quantity = 80,
    VoidCallback? onIncrement,
    VoidCallback? onDecrement,
  }) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: Scaffold(
          body: Center(
            child: ProductQuantityStepper(
              quantity: quantity,
              onIncrement: onIncrement ?? () {},
              onDecrement: onDecrement ?? () {},
            ),
          ),
        ),
      ),
    );
  }

  Finder button(String label) => find.bySemanticsLabel(label);

  testWidgets('shows the quantity', (tester) async {
    await pumpStepper(tester, quantity: 120);

    expect(find.text('120'), findsOneWidget);
  });

  testWidgets('is 86 wide: two 24 buttons and a 32 number, 3 apart', (tester) async {
    await pumpStepper(tester);

    expect(tester.getSize(find.byType(ProductQuantityStepper)).width, 86);
  });

  testWidgets('is 8 taller than the buttons look, above and below', (tester) async {
    await pumpStepper(tester);

    expect(tester.getSize(find.byType(ProductQuantityStepper)).height, 24 + 2 * 8);
  });

  testWidgets('reads plus, number, minus from the left', (tester) async {
    await pumpStepper(tester);
    final semantics = tester.ensureSemantics();

    final plusX = tester.getCenter(button('زيادة الكمية')).dx;
    final numberX = tester.getCenter(find.text('80')).dx;
    final minusX = tester.getCenter(button('إنقاص الكمية')).dx;

    expect(plusX, lessThan(numberX));
    expect(numberX, lessThan(minusX));
    semantics.dispose();
  });

  testWidgets('the buttons are drawn as 24 squares', (tester) async {
    await pumpStepper(tester);
    final semantics = tester.ensureSemantics();

    for (final label in ['زيادة الكمية', 'إنقاص الكمية']) {
      final drawn = find.descendant(of: button(label), matching: find.byType(Container));
      expect(tester.getSize(drawn), const Size(24, 24), reason: label);
    }
    semantics.dispose();
  });

  testWidgets('a tap just above or below a button, in its touch area, still counts', (
    tester,
  ) async {
    var increments = 0;
    var decrements = 0;
    await pumpStepper(tester, onIncrement: () => increments++, onDecrement: () => decrements++);
    final semantics = tester.ensureSemantics();
    final plus = tester.getCenter(button('زيادة الكمية'));
    final minus = tester.getCenter(button('إنقاص الكمية'));

    // 12 is the edge of the drawn square: 18 is 6 past it, inside the 8.
    await tester.tapAt(plus + const Offset(0, -18));
    await tester.tapAt(minus + const Offset(0, 18));

    expect((increments, decrements), (1, 1));
    semantics.dispose();
  });

  testWidgets('a tap beyond the touch area does not count', (tester) async {
    var increments = 0;
    await pumpStepper(tester, onIncrement: () => increments++);
    final semantics = tester.ensureSemantics();

    await tester.tapAt(tester.getCenter(button('زيادة الكمية')) + const Offset(0, -24));

    expect(increments, 0);
    semantics.dispose();
  });

  testWidgets('a tap on the number is swallowed instead of reaching what is behind', (
    tester,
  ) async {
    var behind = 0;
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: Scaffold(
          body: Center(
            child: GestureDetector(
              onTap: () => behind++,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: ProductQuantityStepper(quantity: 80, onIncrement: () {}, onDecrement: () {}),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('80'));
    // Between the number and a button.
    await tester.tapAt(tester.getCenter(find.text('80')) + const Offset(-17, 0));
    expect(behind, 0);

    // The padding around the stepper is not part of it.
    await tester.tapAt(tester.getTopLeft(find.byType(ProductQuantityStepper)) - const Offset(5, 5));
    expect(behind, 1);
  });

  testWidgets('tapping plus and minus calls back once each', (tester) async {
    var increments = 0;
    var decrements = 0;
    await pumpStepper(tester, onIncrement: () => increments++, onDecrement: () => decrements++);
    final semantics = tester.ensureSemantics();

    await tester.tap(button('زيادة الكمية'));
    expect((increments, decrements), (1, 0));

    await tester.tap(button('إنقاص الكمية'));
    expect((increments, decrements), (1, 1));
    semantics.dispose();
  });

  testWidgets('a long number widens the stepper instead of overflowing', (tester) async {
    await pumpStepper(tester, quantity: 1234567);

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(ProductQuantityStepper)).width, greaterThan(86));
  });
}
