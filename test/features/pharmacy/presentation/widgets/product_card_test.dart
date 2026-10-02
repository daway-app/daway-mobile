import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/presentation/widgets/product_card.dart';
import 'package:daway_app/features/pharmacy/presentation/widgets/product_quantity_stepper.dart';
import 'package:daway_app/features/pharmacy/presentation/widgets/product_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';

const _medicine = Medicine(
  id: 1,
  medicineId: 5,
  name: 'Amoxicillin',
  nameAr: 'أموكسيسيلين 500 مج',
  activeIngredient: 'مضادات حيوية',
  price: 18,
  quantity: 120,
  isAvailable: true,
);

// A short name, so the layout tests do not depend on how wide the test font
// draws one line: the name has to share its line with the badge.
const _short = Medicine(
  id: 3,
  medicineId: 7,
  name: 'Panadol',
  nameAr: 'بانادول',
  activeIngredient: 'مضادات حيوية',
  price: 18,
  quantity: 120,
  isAvailable: true,
);

void main() {
  Future<void> pumpCard(
    WidgetTester tester, {
    Medicine medicine = _medicine,
    int? quantity,
    MedicineStatus status = MedicineStatus.available,
    VoidCallback? onTap,
    VoidCallback? onIncrement,
    VoidCallback? onDecrement,
  }) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            // The width the page gives it: 440 less 24 either side.
            child: SizedBox(
              width: 392,
              child: ProductCard(
                medicine: medicine,
                quantity: quantity ?? medicine.quantity,
                status: status,
                onTap: onTap ?? () {},
                onIncrement: onIncrement ?? () {},
                onDecrement: onDecrement ?? () {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows the Arabic name, the ingredient, the price and the quantity', (tester) async {
    await pumpCard(tester);

    expect(find.text('أموكسيسيلين 500 مج'), findsOneWidget);
    expect(find.text('مضادات حيوية'), findsOneWidget);
    expect(find.text('₪ 18'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);
  });

  testWidgets('falls back to the English name when there is no Arabic one', (tester) async {
    await pumpCard(
      tester,
      medicine: const Medicine(
        id: 2,
        medicineId: 6,
        name: 'Panadol',
        price: 9,
        quantity: 4,
        isAvailable: true,
      ),
    );

    expect(find.text('Panadol'), findsOneWidget);
  });

  testWidgets('a price with cents keeps two decimals', (tester) async {
    await pumpCard(
      tester,
      medicine: const Medicine(
        id: 2,
        medicineId: 6,
        name: 'Panadol',
        price: 12.5,
        quantity: 4,
        isAvailable: true,
      ),
    );

    expect(find.text('₪ 12.50'), findsOneWidget);
  });

  testWidgets('shows the quantity and the status it is given, not the medicine own', (tester) async {
    await pumpCard(tester, quantity: 3, status: MedicineStatus.low);

    expect(find.text('3'), findsOneWidget);
    expect(find.text('120'), findsNothing);
    expect(find.text('مخزون منخفض'), findsOneWidget);
    expect(tester.widget<ProductStatusBadge>(find.byType(ProductStatusBadge)).status, MedicineStatus.low);
  });

  testWidgets('a medicine with no active ingredient shows no ingredient line', (tester) async {
    await pumpCard(
      tester,
      medicine: const Medicine(
        id: 2,
        medicineId: 6,
        name: 'Panadol',
        price: 9,
        quantity: 4,
        isAvailable: true,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('₪ 9'), findsOneWidget);
  });

  testWidgets('an all-caps Latin ingredient is shown in lower case', (tester) async {
    await pumpCard(
      tester,
      medicine: const Medicine(
        id: 2,
        medicineId: 6,
        name: 'Panadol',
        activeIngredient: 'PARACETAMOL',
        price: 9,
        quantity: 4,
        isAvailable: true,
      ),
    );

    expect(find.text('paracetamol'), findsOneWidget);
  });

  group('layout at the design size', () {
    testWidgets('is 392 wide and 106 tall', (tester) async {
      await pumpCard(tester, medicine: _short);

      expect(tester.getSize(find.byType(ProductCard)), const Size(392, 106));
    });

    testWidgets('the picture is a 62 square, 8 in from the right and centered on the card', (
      tester,
    ) async {
      await pumpCard(tester, medicine: _short);

      final card = tester.getRect(find.byType(ProductCard));
      final image = tester.getRect(
        find.descendant(
          of: find.byType(ProductCard),
          matching: find.byWidgetPredicate(
            (widget) => widget is Container && widget.clipBehavior == Clip.antiAlias,
          ),
        ),
      );

      expect(image.size, const Size(62, 62));
      // Inside the 1px border.
      expect(card.right - 1 - image.right, 8);
      expect(image.center.dy, card.center.dy);
    });

    testWidgets('the name is 12 to the left of the picture, and the badge 12 in from the left', (
      tester,
    ) async {
      await pumpCard(tester, medicine: _short);

      final card = tester.getRect(find.byType(ProductCard));
      final image = tester.getRect(
        find.descendant(
          of: find.byType(ProductCard),
          matching: find.byWidgetPredicate(
            (widget) => widget is Container && widget.clipBehavior == Clip.antiAlias,
          ),
        ),
      );
      final name = tester.getRect(find.text('بانادول'));
      final badge = tester.getRect(find.byType(ProductStatusBadge));

      expect(name.right, lessThanOrEqualTo(image.left - 12 + 0.01));
      expect(badge.left - card.left, 1 + 12);
      expect(badge.top - card.top, 1 + 12);
    });

    testWidgets('the stepper is 12 in from the left, and level with the price', (tester) async {
      await pumpCard(tester, medicine: _short);

      final card = tester.getRect(find.byType(ProductCard));
      final stepper = tester.getRect(find.byType(ProductQuantityStepper));
      final price = tester.getRect(find.text('₪ 18'));

      expect(stepper.left - card.left, 1 + 12);
      expect(price.center.dy, closeTo(stepper.center.dy, 0.5));
      expect(price.right, greaterThan(stepper.right));
    });

    testWidgets('a long name wraps to two lines and the card grows with it', (tester) async {
      await pumpCard(
        tester,
        medicine: const Medicine(
          id: 2,
          medicineId: 6,
          name: 'X',
          nameAr: 'أموكسيسيلين وحمض الكلافولانيك 875 مج و125 مج أقراص مغلفة للأطفال والكبار',
          activeIngredient: 'مضادات حيوية',
          price: 18,
          quantity: 120,
          isAvailable: true,
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(ProductCard)).height, greaterThan(106));
    });
  });

  testWidgets('tapping the card calls onTap', (tester) async {
    var taps = 0;
    await pumpCard(tester, onTap: () => taps++);

    await tester.tap(find.text('أموكسيسيلين 500 مج'));

    expect(taps, 1);
  });

  testWidgets('a tap on the quantity does not open the card', (tester) async {
    var taps = 0;
    await pumpCard(tester, onTap: () => taps++);

    await tester.tap(find.text('120'));

    expect(taps, 0);
  });

  testWidgets('the stepper buttons call their own callbacks, not the card tap', (tester) async {
    var taps = 0;
    var increments = 0;
    var decrements = 0;
    await pumpCard(
      tester,
      onTap: () => taps++,
      onIncrement: () => increments++,
      onDecrement: () => decrements++,
    );
    final semantics = tester.ensureSemantics();

    await tester.tap(find.bySemanticsLabel('زيادة الكمية'));
    await tester.tap(find.bySemanticsLabel('إنقاص الكمية'));

    expect((taps, increments, decrements), (0, 1, 1));
    semantics.dispose();
  });
}
