import 'package:daway_app/core/models/picked_location.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/features/patient/presentation/screens/patient_addresses_screen.dart';
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

  /// The map picker route is stubbed with a screen that pops [picked] (or
  /// nothing) as soon as it is shown, standing in for the real picker.
  Widget buildTestableScreen({
    List<String>? visitedRoutes,
    PickedLocation? picked,
  }) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        // The app theme's page background (AppTheme.lightTheme is not used
        // here: it pulls in google_fonts, which the tests keep off).
        theme: ThemeData(scaffoldBackgroundColor: Colors.white),
        onGenerateRoute: (settings) {
          visitedRoutes?.add(settings.name ?? '');
          return MaterialPageRoute<PickedLocation>(
            builder: (routeContext) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(routeContext).pop(picked);
              });
              return const Scaffold(body: SizedBox.shrink());
            },
          );
        },
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: PatientAddressesScreen(),
        ),
      ),
    );
  }

  testWidgets('shows the empty state, with no address list button, when nothing is saved', (
    tester,
  ) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    expect(find.text('عناويني'), findsOneWidget);
    expect(find.text('لا يوجد عناوين محفوظة'), findsOneWidget);
    expect(find.text('أضف عنوان'), findsOneWidget);
    expect(find.text('اضافة عنوان'), findsNothing); // the list's own add button
  });

  testWidgets('the page is on a white background, like the other patient screens', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    // The Scaffold paints its background with the first Material under it.
    final page = tester.widget<Material>(
      find.descendant(of: find.byType(Scaffold), matching: find.byType(Material)).first,
    );
    expect(page.color, Colors.white);
  });

  testWidgets('tapping "أضف عنوان" opens the location picker', (tester) async {
    await setPhoneViewport(tester);
    final visitedRoutes = <String>[];

    await tester.pumpWidget(buildTestableScreen(visitedRoutes: visitedRoutes));
    await tester.pumpAndSettle();
    await tester.tap(find.text('أضف عنوان'));
    await tester.pumpAndSettle();

    expect(visitedRoutes, contains(Routes.locationPickerScreen));
  });

  testWidgets('a picked location replaces the empty state with an address card', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(
      buildTestableScreen(
        picked: const PickedLocation(
          latitude: 31.5,
          longitude: 34.46,
          address: 'غزة - الرمال - مقابل فلافل السوسي',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('أضف عنوان'));
    await tester.pumpAndSettle();

    expect(find.text('لا يوجد عناوين محفوظة'), findsNothing);
    expect(find.text('المنزل'), findsOneWidget);
    expect(find.text('غزة - الرمال - مقابل فلافل السوسي'), findsOneWidget);
    expect(find.text('اضافة عنوان'), findsOneWidget);
  });
}
