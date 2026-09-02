import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/presentation/widgets/medicine_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpCard(WidgetTester tester, Medicine medicine) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: MedicineCard(medicine: medicine, onEdit: () {}, onDelete: () {}),
          ),
        ),
      ),
    );
  }

  testWidgets('shows the price with the shekel symbol, not a riyal', (
    tester,
  ) async {
    await pumpCard(
      tester,
      const Medicine(
        id: 1,
        medicineId: 1,
        name: 'Panadol Extra',
        price: 12.5,
        quantity: 40,
        isAvailable: true,
      ),
    );

    expect(find.textContaining('₪'), findsOneWidget);
    expect(find.textContaining('ر.س'), findsNothing);
  });

  testWidgets('shows both the Arabic and English trade names when both exist', (
    tester,
  ) async {
    await pumpCard(
      tester,
      const Medicine(
        id: 1,
        medicineId: 1,
        name: 'Panadol Extra',
        nameAr: 'بنادول اكسترا',
        price: 12.5,
        quantity: 40,
        isAvailable: true,
      ),
    );

    expect(find.text('بنادول اكسترا'), findsOneWidget);
    expect(find.text('Panadol Extra'), findsOneWidget);
  });

  testWidgets('falls back to the English name alone when there is no Arabic name', (
    tester,
  ) async {
    await pumpCard(
      tester,
      const Medicine(
        id: 1,
        medicineId: 1,
        name: 'Panadol Extra',
        price: 12.5,
        quantity: 40,
        isAvailable: true,
      ),
    );

    expect(find.text('Panadol Extra'), findsOneWidget);
  });

  testWidgets('lowercases an all-caps active ingredient', (tester) async {
    await pumpCard(
      tester,
      const Medicine(
        id: 1,
        medicineId: 1,
        name: 'Panadol Extra',
        activeIngredient: 'PARACETAMOL',
        price: 12.5,
        quantity: 40,
        isAvailable: true,
      ),
    );

    expect(find.text('paracetamol'), findsOneWidget);
    expect(find.text('PARACETAMOL'), findsNothing);
  });

  testWidgets('leaves a normally-cased active ingredient untouched', (
    tester,
  ) async {
    await pumpCard(
      tester,
      const Medicine(
        id: 1,
        medicineId: 1,
        name: 'Panadol Extra',
        activeIngredient: 'Paracetamol',
        price: 12.5,
        quantity: 40,
        isAvailable: true,
      ),
    );

    expect(find.text('Paracetamol'), findsOneWidget);
  });
}
