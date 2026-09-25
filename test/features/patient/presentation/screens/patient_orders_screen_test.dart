import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/features/patient/domain/entities/order.dart';
import 'package:daway_app/features/patient/presentation/screens/patient_orders_screen.dart';
import 'package:daway_app/features/patient/presentation/widgets/order_card.dart';
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

  Widget buildTestableScreen({List<String>? visitedRoutes, List<Order> orders = const []}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        onGenerateRoute: (settings) {
          visitedRoutes?.add(settings.name ?? '');
          return MaterialPageRoute(builder: (_) => const Scaffold(body: SizedBox.shrink()));
        },
        home: PatientOrdersScreen(orders: orders),
      ),
    );
  }

  testWidgets('shows the header and the empty-orders state (no orders backend yet)', (
    tester,
  ) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    expect(find.text('طلباتي'), findsOneWidget);
    expect(find.text('تابع طلباتك وراجع سجل مشترياتك'), findsOneWidget);
    expect(find.text('لا يوجد طلبات'), findsOneWidget);
    expect(find.text('أضف الطلبات حتى تتمكن من تتبعها'), findsOneWidget);
    expect(find.text('تصفح الاقسام'), findsOneWidget);
    expect(find.text('الكل (0)'), findsNothing); // status tabs only show once there are orders
  });

  testWidgets('the "تصفح الاقسام" button is sized to its text, not stretched full-width', (
    tester,
  ) async {
    // Regression test: Container's `alignment` property makes it expand to
    // fill its parent once bounded constraints reach it, even with no
    // explicit width — this button doesn't need `alignment` at all (a
    // single Text + padding is already positioned correctly without it).
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    final buttonSize = tester.getSize(
      find.ancestor(of: find.text('تصفح الاقسام'), matching: find.byType(Container)).first,
    );

    // Content-sized renders around 162 in this viewport; the bug this
    // guards against stretched it to the full ~327-wide content column.
    expect(buttonSize.width, lessThan(200));
  });

  testWidgets('tapping "تصفح الاقسام" navigates to all-categories', (tester) async {
    await setPhoneViewport(tester);
    final visitedRoutes = <String>[];

    await tester.pumpWidget(buildTestableScreen(visitedRoutes: visitedRoutes));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تصفح الاقسام'));
    await tester.pumpAndSettle();

    expect(visitedRoutes, contains(Routes.allCategoriesScreen));
  });

  testWidgets('the back button pops the screen', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PatientOrdersScreen()),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('طلباتي'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('authBackButton')));
    await tester.pumpAndSettle();

    expect(find.text('طلباتي'), findsNothing);
  });

  group('with orders', () {
    // Fixed dates: nothing here depends on the clock.
    Order order(String number, OrderStatus status, {int items = 1, double price = 65}) => Order(
          orderNumber: number,
          pharmacyName: 'صيدلية $number',
          status: status,
          itemsCount: items,
          price: price,
          address: 'غزة - الرمال',
          createdAt: DateTime(2020, 1, 1, 9, 30),
        );

    final orders = [
      order('A1', OrderStatus.completed),
      order('A2', OrderStatus.inProgress),
      order('A3', OrderStatus.inProgress),
    ];

    testWidgets('shows the status tabs with their counts and every order, not the empty state', (
      tester,
    ) async {
      await setPhoneViewport(tester);

      await tester.pumpWidget(buildTestableScreen(orders: orders));
      await tester.pumpAndSettle();

      expect(find.text('الكل (3)'), findsOneWidget);
      expect(find.text('مكتملة (1)'), findsOneWidget);
      expect(find.text('قيد التنفيذ (2)'), findsOneWidget);
      expect(find.text('ملغاة (0)'), findsOneWidget);
      expect(find.byType(OrderCard), findsNWidgets(3));
      expect(find.text('لا يوجد طلبات'), findsNothing);
    });

    testWidgets('tapping a status keeps only the orders in that status', (tester) async {
      await setPhoneViewport(tester);
      await tester.pumpWidget(buildTestableScreen(orders: orders));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('قيد التنفيذ (2)'));
      await tester.tap(find.text('قيد التنفيذ (2)'));
      await tester.pumpAndSettle();

      expect(find.byType(OrderCard), findsNWidgets(2));
      expect(find.text('#A1'), findsNothing);
      expect(find.text('#A2'), findsOneWidget);
    });

    testWidgets('a status with no orders says so under the tabs, which stay', (tester) async {
      await setPhoneViewport(tester);
      await tester.pumpWidget(buildTestableScreen(orders: orders));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('ملغاة (0)'));
      await tester.tap(find.text('ملغاة (0)'));
      await tester.pumpAndSettle();

      expect(find.byType(OrderCard), findsNothing);
      expect(find.text('لا يوجد طلبات'), findsOneWidget);
      expect(find.text('الكل (3)'), findsOneWidget);
    });

    testWidgets('going back to "الكل" shows every order again', (tester) async {
      await setPhoneViewport(tester);
      await tester.pumpWidget(buildTestableScreen(orders: orders));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('مكتملة (1)'));
      await tester.tap(find.text('مكتملة (1)'));
      await tester.pumpAndSettle();
      expect(find.byType(OrderCard), findsOneWidget);

      await tester.ensureVisible(find.text('الكل (3)'));
      await tester.tap(find.text('الكل (3)'));
      await tester.pumpAndSettle();

      expect(find.byType(OrderCard), findsNWidgets(3));
    });

    testWidgets('"عرض الطلب" shows the "قريباً" cue until the order details exist', (tester) async {
      await setPhoneViewport(tester);
      await tester.pumpWidget(buildTestableScreen(orders: [order('A1', OrderStatus.completed)]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('عرض الطلب'));
      await tester.pump();

      expect(find.text('قريباً'), findsOneWidget);
    });
  });
}
