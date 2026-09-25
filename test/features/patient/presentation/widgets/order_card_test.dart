import 'package:daway_app/features/patient/domain/entities/order.dart';
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

  // RTL like the real app (app.dart sets `locale: Locale('ar')`) — the
  // card's layout is right-to-left, so it has to be tested that way.
  Widget buildTestable(Order order, {VoidCallback? onViewTap}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: OrderCard(order: order, onViewTap: onViewTap ?? () {}),
          ),
        ),
      ),
    );
  }

  testWidgets('shows the pharmacy name, order number, status, and summary fields', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    final order = Order(
      orderNumber: 'DW-1022',
      pharmacyName: 'صيدلية الهدى',
      status: OrderStatus.inProgress,
      itemsCount: 1,
      price: 65,
      address: 'غزة - الشجاعية',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(buildTestable(order));

    expect(find.text('صيدلية الهدى'), findsOneWidget);
    expect(find.text('#DW-1022'), findsOneWidget);
    expect(find.text('قيد التنفيذ'), findsOneWidget);
    expect(find.text('غزة - الشجاعية'), findsOneWidget);
    expect(find.text('65 ₪'), findsOneWidget);
    expect(find.text('دواء واحد'), findsOneWidget);
  });

  testWidgets('uses the plural item-count form for more than one item', (tester) async {
    await setPhoneViewport(tester);
    final order = Order(
      orderNumber: 'DW-1021',
      pharmacyName: 'صيدلية النور',
      status: OrderStatus.completed,
      itemsCount: 2,
      price: 80,
      address: 'غزة - النصر',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(buildTestable(order));

    expect(find.text('دواءان'), findsOneWidget);
    expect(find.text('مكتمل'), findsOneWidget);
  });

  testWidgets('the item count agrees with its noun: 5 أدوية but 11 دواء', (tester) async {
    await setPhoneViewport(tester);
    Order orderWithItems(int count) => Order(
          orderNumber: 'DW-1',
          pharmacyName: 'صيدلية النور',
          status: OrderStatus.completed,
          itemsCount: count,
          price: 80,
          address: 'غزة - النصر',
          createdAt: DateTime.now(),
        );

    await tester.pumpWidget(buildTestable(orderWithItems(5)));
    expect(find.text('5 أدوية'), findsOneWidget);

    await tester.pumpWidget(buildTestable(orderWithItems(11)));
    expect(find.text('11 دواء'), findsOneWidget);
  });

  testWidgets('a long absolute date next to the button does not overflow the card', (tester) async {
    // An old order shows "1 يناير 2020، 9:30 ص" instead of a short "اليوم، ...";
    // the wide test font makes the row's worst case visible.
    await setPhoneViewport(tester);
    final order = Order(
      orderNumber: 'DW-1',
      pharmacyName: 'صيدلية النور',
      status: OrderStatus.completed,
      itemsCount: 1,
      price: 80,
      address: 'غزة - النصر',
      createdAt: DateTime(2020, 1, 1, 9, 30),
    );

    await tester.pumpWidget(buildTestable(order));

    expect(tester.takeException(), isNull);
    expect(find.text('عرض الطلب'), findsOneWidget);
  });

  testWidgets('a fractional price keeps its decimals instead of being rounded', (tester) async {
    await setPhoneViewport(tester);
    final order = Order(
      orderNumber: 'DW-1',
      pharmacyName: 'صيدلية النور',
      status: OrderStatus.completed,
      itemsCount: 1,
      price: 19.9,
      address: 'غزة - النصر',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(buildTestable(order));

    expect(find.text('19.90 ₪'), findsOneWidget);
  });

  testWidgets('shows the cancelled label for a cancelled order', (tester) async {
    await setPhoneViewport(tester);
    final order = Order(
      orderNumber: 'DW-1023',
      pharmacyName: 'صيدلية الأمل',
      status: OrderStatus.cancelled,
      itemsCount: 3,
      price: 95,
      address: 'غزة - الرمال',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(buildTestable(order));

    expect(find.text('ملغي'), findsOneWidget);
  });

  testWidgets('lays out right-to-left like the design', (tester) async {
    await setPhoneViewport(tester);
    final order = Order(
      orderNumber: 'DW-1022',
      pharmacyName: 'صيدلية الهدى',
      status: OrderStatus.inProgress,
      itemsCount: 1,
      price: 65,
      address: 'غزة - الشجاعية',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(buildTestable(order));

    final card = tester.getRect(find.byType(OrderCard));
    final name = tester.getRect(find.text('صيدلية الهدى'));
    final badge = tester.getRect(find.text('قيد التنفيذ'));

    // Pharmacy name hugs the right edge, the status badge sits at the left.
    expect(card.right - name.right, lessThan(16));
    expect(badge.center.dx, lessThan(card.center.dx));

    // Summary strip, right to left: items count, price, location.
    final items = tester.getRect(find.text('دواء واحد')).center.dx;
    final price = tester.getRect(find.text('65 ₪')).center.dx;
    final location = tester.getRect(find.text('غزة - الشجاعية')).center.dx;
    expect(items, greaterThan(price));
    expect(price, greaterThan(location));

    // "عرض الطلب" at the right, the timestamp at the left.
    final viewButton = tester.getRect(find.text('عرض الطلب')).center.dx;
    final time = tester.getRect(find.textContaining('اليوم')).center.dx;
    expect(viewButton, greaterThan(time));
  });

  testWidgets('tapping "عرض الطلب" invokes onViewTap', (tester) async {
    await setPhoneViewport(tester);
    var tapped = false;
    final order = Order(
      orderNumber: 'DW-1021',
      pharmacyName: 'صيدلية النور',
      status: OrderStatus.completed,
      itemsCount: 2,
      price: 80,
      address: 'غزة - النصر',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(buildTestable(order, onViewTap: () => tapped = true));
    await tester.tap(find.text('عرض الطلب'));

    expect(tapped, isTrue);
  });
}
