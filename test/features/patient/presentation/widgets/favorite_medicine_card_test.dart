import 'package:daway_app/features/patient/domain/entities/favorite_medicine.dart';
import 'package:daway_app/features/patient/presentation/widgets/favorite_medicine_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // RTL like the real app (app.dart sets `locale: Locale('ar')`) — the
  // card's layout is right-to-left, so it has to be tested that way.
  Widget buildTestable(FavoriteMedicine medicine, {VoidCallback? onCompareTap}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: FavoriteMedicineCard(medicine: medicine, onCompareTap: onCompareTap ?? () {}),
          ),
        ),
      ),
    );
  }

  testWidgets('shows the Arabic name as primary and English as secondary when both exist', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    const medicine = FavoriteMedicine(
      medicineId: 1,
      tradeName: 'Panadol Extra',
      tradeNameAr: 'باندول إكسترا',
      isAvailable: true,
      pharmaciesCount: 3,
      minPrice: 12,
    );

    await tester.pumpWidget(buildTestable(medicine));

    expect(find.text('باندول إكسترا'), findsOneWidget);
    expect(find.text('Panadol Extra'), findsOneWidget);
    expect(find.text('متوفر في 3 صيدليات'), findsOneWidget);
    expect(find.text('12 ₪'), findsOneWidget);
    expect(find.text('مقارنة الأسعار'), findsOneWidget);
  });

  testWidgets('the availability line agrees with the number of pharmacies', (tester) async {
    await setPhoneViewport(tester);
    FavoriteMedicine medicineIn(int pharmacies) => FavoriteMedicine(
          medicineId: 1,
          tradeName: 'Panadol',
          isAvailable: true,
          pharmaciesCount: pharmacies,
          minPrice: 60,
        );

    for (final (count, label) in [
      (1, 'متوفر في صيدلية واحدة'),
      (2, 'متوفر في صيدليتين'),
      (5, 'متوفر في 5 صيدليات'),
      (11, 'متوفر في 11 صيدلية'),
    ]) {
      await tester.pumpWidget(buildTestable(medicineIn(count)));
      expect(find.text(label), findsOneWidget, reason: '$count pharmacies');
    }
  });

  testWidgets('a fractional price keeps its decimals instead of being rounded', (tester) async {
    await setPhoneViewport(tester);
    const medicine = FavoriteMedicine(
      medicineId: 1,
      tradeName: 'Panadol',
      isAvailable: true,
      pharmaciesCount: 2,
      minPrice: 12.5,
    );

    await tester.pumpWidget(buildTestable(medicine));

    expect(find.text('12.50 ₪'), findsOneWidget);
  });

  testWidgets('falls back to the English name alone when there is no Arabic name', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    const medicine = FavoriteMedicine(
      medicineId: 1,
      tradeName: 'Panadol',
      isAvailable: true,
      pharmaciesCount: 1,
      minPrice: 60,
    );

    await tester.pumpWidget(buildTestable(medicine));

    expect(find.text('Panadol'), findsOneWidget); // shown once, as the primary name
    expect(find.text('يبدأ من '), findsOneWidget);
  });

  testWidgets('shows an unavailable message and no price when nothing is in stock', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    const medicine = FavoriteMedicine(
      medicineId: 1,
      tradeName: 'Aspirin',
      isAvailable: false,
      pharmaciesCount: 0,
    );

    await tester.pumpWidget(buildTestable(medicine));

    expect(find.text('غير متوفر حالياً'), findsOneWidget);
    expect(find.text('يبدأ من '), findsNothing);
  });

  testWidgets('lays out right-to-left: thumbnail at the right, names beside it', (tester) async {
    await setPhoneViewport(tester);
    const medicine = FavoriteMedicine(
      medicineId: 1,
      tradeName: 'Panadol Extra',
      tradeNameAr: 'باندول إكسترا',
      isAvailable: true,
      pharmaciesCount: 3,
      minPrice: 12,
    );

    await tester.pumpWidget(buildTestable(medicine));

    final card = tester.getRect(find.byType(FavoriteMedicineCard));
    // The 56x56 thumbnail box around the placeholder icon.
    final thumbnail = tester.getRect(
      find.ancestor(of: find.byIcon(Icons.medication_outlined), matching: find.byType(Container)).first,
    );
    final name = tester.getRect(find.text('باندول إكسترا'));

    // Thumbnail on the right edge, the name to its left, hugging the 14 gap
    // (right-aligned against the thumbnail).
    expect(thumbnail.center.dx, greaterThan(card.center.dx));
    expect(name.center.dx, lessThan(thumbnail.center.dx));
    expect(thumbnail.left - name.right, closeTo(14, 1));

    // Availability strip: text at the right, "يبدأ من" price at the left.
    final availability = tester.getRect(find.text('متوفر في 3 صيدليات')).center.dx;
    final price = tester.getRect(find.text('12 ₪')).center.dx;
    expect(availability, greaterThan(price));
  });

  testWidgets('tapping "مقارنة الأسعار" invokes onCompareTap', (tester) async {
    await setPhoneViewport(tester);
    var tapped = false;
    const medicine = FavoriteMedicine(
      medicineId: 1,
      tradeName: 'Panadol',
      isAvailable: true,
      pharmaciesCount: 1,
      minPrice: 60,
    );

    await tester.pumpWidget(buildTestable(medicine, onCompareTap: () => tapped = true));
    await tester.tap(find.text('مقارنة الأسعار'));

    expect(tapped, isTrue);
  });
}
