import 'package:daway_app/features/patient/domain/entities/category_medicine.dart';
import 'package:daway_app/features/patient/domain/entities/searched_medicine.dart';
import 'package:daway_app/features/patient/presentation/widgets/category_medicine_card.dart';
import 'package:daway_app/features/patient/presentation/widgets/medicine_grid_card.dart';
import 'package:daway_app/features/patient/presentation/widgets/searched_medicine_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> setViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // RTL like the real app, in a 184x201 cell like the results grid gives it.
  Widget buildTestable(Widget card) {
    return ScreenUtilInit(
      designSize: const Size(440, 956),
      builder: (context, child) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Center(child: SizedBox(width: 184, height: 201, child: card)),
          ),
        ),
      ),
    );
  }

  group('MedicineGridCard', () {
    testWidgets('shows the media, the title, the subtitle and the details button', (tester) async {
      await setViewport(tester);
      var tapped = 0;

      await tester.pumpWidget(
        buildTestable(
          MedicineGridCard(
            media: const Icon(Icons.abc, key: ValueKey('media')),
            title: 'Panadol',
            subtitle: 'Paracetamol',
            detailsLabel: 'عرض',
            onDetailsTap: () => tapped++,
          ),
        ),
      );

      expect(find.byKey(const ValueKey('media')), findsOneWidget);
      expect(find.text('Panadol'), findsOneWidget);
      expect(find.text('Paracetamol'), findsOneWidget);
      await tester.tap(find.text('عرض'));
      expect(tapped, 1);
    });

    testWidgets('leaves the subtitle out when it is null or empty', (tester) async {
      await setViewport(tester);
      Widget card(String? subtitle) => buildTestable(
            MedicineGridCard(
              media: const SizedBox.shrink(),
              title: 'Panadol',
              subtitle: subtitle,
              detailsLabel: 'عرض',
              onDetailsTap: () {},
            ),
          );

      await tester.pumpWidget(card(null));
      expect(find.byType(Text), findsNWidgets(2)); // title + button label

      await tester.pumpWidget(card(''));
      expect(find.byType(Text), findsNWidgets(2));
    });

    testWidgets('the subtitle takes the given color, and the text is right-aligned', (tester) async {
      await setViewport(tester);

      await tester.pumpWidget(
        buildTestable(
          MedicineGridCard(
            media: const SizedBox.shrink(),
            title: 'Panadol',
            subtitle: 'متوفر',
            subtitleColor: Colors.green,
            detailsLabel: 'عرض',
            onDetailsTap: () {},
          ),
        ),
      );

      final subtitle = tester.widget<Text>(find.text('متوفر'));
      expect(subtitle.style!.color, Colors.green);
      expect(subtitle.textAlign, TextAlign.right);
      final card = tester.getRect(find.byType(MedicineGridCard));
      final button = tester.getRect(find.byType(OutlinedButton));
      // The details button sits at the left: 8 in from the card's 1px border.
      expect(button.left - card.left, closeTo(9, 0.5));
    });
  });

  group('CategoryMedicineCard', () {
    testWidgets('shows the stand-in icon, the generic name and its own button label', (tester) async {
      await setViewport(tester);

      await tester.pumpWidget(
        buildTestable(
          CategoryMedicineCard(
            medicine: const CategoryMedicine(
              id: 1,
              tradeName: 'Panadol',
              genericName: 'Paracetamol',
            ),
            onDetailsTap: () {},
          ),
        ),
      );

      expect(find.byType(MedicinePlaceholderIcon), findsOneWidget);
      expect(find.text('Panadol'), findsOneWidget);
      expect(find.text('Paracetamol'), findsOneWidget);
      expect(find.text('عرض تفاصيل'), findsOneWidget);
    });
  });

  group('SearchedMedicineCard', () {
    Widget searched(SearchedMedicine medicine) =>
        buildTestable(SearchedMedicineCard(medicine: medicine, onDetailsTap: () {}));

    testWidgets('shows an availability line that agrees with the pharmacy count', (tester) async {
      await setViewport(tester);

      for (final (count, label) in [
        (1, 'متوفر في صيدلية واحدة'),
        (2, 'متوفر في صيدليتين'),
        (5, 'متوفر في 5 صيدليات'),
        (11, 'متوفر في 11 صيدلية'),
      ]) {
        await tester.pumpWidget(
          searched(
            SearchedMedicine(
              id: 1,
              tradeName: 'Panadol',
              isAvailable: true,
              availablePharmaciesCount: count,
            ),
          ),
        );
        expect(find.text(label), findsOneWidget, reason: '$count pharmacies');
      }
    });

    testWidgets('says so, in grey, when no pharmacy has it', (tester) async {
      await setViewport(tester);

      await tester.pumpWidget(
        searched(
          const SearchedMedicine(
            id: 1,
            tradeName: 'Panadol',
            isAvailable: false,
            availablePharmaciesCount: 0,
          ),
        ),
      );

      final line = tester.widget<Text>(find.text('غير متوفر حالياً'));
      expect(line.style!.color, const Color(0xFF757575));
    });

    testWidgets('uses the stand-in icon when the medicine has no image', (tester) async {
      await setViewport(tester);

      await tester.pumpWidget(
        searched(
          const SearchedMedicine(
            id: 1,
            tradeName: 'Panadol',
            isAvailable: true,
            availablePharmaciesCount: 1,
          ),
        ),
      );

      expect(find.byType(MedicinePlaceholderIcon), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(find.text('عرض التفاصيل'), findsOneWidget);
    });
  });
}
