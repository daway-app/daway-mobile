import 'package:daway_app/core/widgets/header_icon_button.dart';
import 'package:daway_app/features/pharmacy/domain/entities/pharmacy_order.dart';
import 'package:daway_app/features/pharmacy/presentation/screens/pharmacy_orders_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';

PharmacyOrder _order(String number) => PharmacyOrder(
  orderNumber: number,
  createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
  itemsCount: 2,
  total: 80,
  area: 'غزة - النصر',
);

void main() {
  Future<void> pumpScreen(WidgetTester tester, {List<PharmacyOrder> orders = const []}) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(buildArabicTestApp(home: PharmacyOrdersScreen(orders: orders)));
  }

  testWidgets('has the title and no back chip, being a tab root', (tester) async {
    await pumpScreen(tester, orders: [_order('DW-1021')]);

    expect(find.text('الطلبات'), findsOneWidget);
    expect(find.text('أدر المنتجات الخاصة بك'), findsOneWidget);
    expect(find.byType(HeaderIconButton), findsNothing);
  });

  testWidgets('shows a card per order', (tester) async {
    await pumpScreen(tester, orders: [_order('DW-1021'), _order('DW-1022'), _order('DW-1023')]);

    expect(find.text('#DW-1021'), findsOneWidget);
    expect(find.text('#DW-1022'), findsOneWidget);
    expect(find.text('#DW-1023'), findsOneWidget);
    expect(find.text('عرض الطلب'), findsNWidgets(3));
  });

  testWidgets('says there are no orders when there are none', (tester) async {
    await pumpScreen(tester);

    expect(find.text('لا توجد طلبات بعد.'), findsOneWidget);
    expect(find.text('عرض الطلب'), findsNothing);
  });

  testWidgets('عرض الطلب opens that order\'s details', (tester) async {
    await pumpScreen(tester, orders: [_order('DW-1021'), _order('DW-1022')]);

    await tester.tap(find.text('عرض الطلب').last);
    await tester.pumpAndSettle();

    expect(find.text('تفاصيل الطلب'), findsOneWidget);
    expect(find.text('#DW-1022'), findsOneWidget);
    expect(find.text('#DW-1021'), findsNothing);
  });
}
