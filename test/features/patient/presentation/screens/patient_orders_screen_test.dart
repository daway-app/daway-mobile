import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/order.dart';
import 'package:daway_app/features/patient/domain/repositories/orders_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/cancel_order_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_orders_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/orders_cubit.dart';
import 'package:daway_app/features/patient/presentation/screens/patient_orders_screen.dart';
import 'package:daway_app/features/patient/presentation/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

Order _order(String number, OrderStatus status, {int items = 1, double price = 65}) => Order(
      orderNumber: number,
      pharmacyName: 'صيدلية $number',
      status: status,
      itemsCount: items,
      price: price,
      address: 'غزة - الرمال',
      createdAt: DateTime(2020, 1, 1, 9, 30),
    );

class _FakeOrdersRepository implements OrdersRepository {

  @override
  Future<ApiResult<void>> cancelOrder({required String token, required int orderId}) async =>
      const Success(null);
  ApiResult<List<Order>> ordersResult = const Success([]);

  @override
  Future<ApiResult<List<Order>>> getOrders({required String token}) async => ordersResult;

  @override
  Future<ApiResult<int>> checkout({
    required String token,
    required int addressId,
    String? couponCode,
    String? notes,
  }) async =>
      const Success(1);
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');

  @override
  Future<void> saveSession(UserSession session) async => savedSession = session;

  @override
  Future<UserSession?> getSession() async => savedSession;

  @override
  Future<void> clearSession() async => savedSession = null;
}

void main() {
  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  final getIt = GetIt.instance;
  late _FakeOrdersRepository repository;

  setUp(() {
    repository = _FakeOrdersRepository();
    getIt.registerFactory<OrdersCubit>(
      () => OrdersCubit(
        GetOrdersUseCase(repository, _FakeSessionRepository()),
        CancelOrderUseCase(repository, _FakeSessionRepository()),
      ),
    );
  });

  tearDown(() => getIt.reset());

  Widget buildTestableScreen({List<String>? visitedRoutes}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        onGenerateRoute: (settings) {
          visitedRoutes?.add(settings.name ?? '');
          return MaterialPageRoute(builder: (_) => const Scaffold(body: SizedBox.shrink()));
        },
        home: const PatientOrdersScreen(),
      ),
    );
  }

  testWidgets('shows the header and the empty-orders state', (tester) async {
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

  testWidgets('a load failure shows the error with a working retry button', (tester) async {
    await setPhoneViewport(tester);
    repository.ordersResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    expect(find.text('تعذر الاتصال بالخادم'), findsOneWidget);
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
    final orders = [
      _order('A1', OrderStatus.delivered),
      _order('A2', OrderStatus.confirmed),
      _order('A3', OrderStatus.preparing),
    ];

    testWidgets('shows the status tabs with their counts and every order, not the empty state', (
      tester,
    ) async {
      await setPhoneViewport(tester);
      repository.ordersResult = Success(orders);

      await tester.pumpWidget(buildTestableScreen());
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
      repository.ordersResult = Success(orders);
      await tester.pumpWidget(buildTestableScreen());
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
      repository.ordersResult = Success(orders);
      await tester.pumpWidget(buildTestableScreen());
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
      repository.ordersResult = Success(orders);
      await tester.pumpWidget(buildTestableScreen());
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

    testWidgets('"عرض الطلب" opens the order sheet, offering cancel only while cancellable',
        (tester) async {
      await setPhoneViewport(tester);
      repository.ordersResult = Success([_order('7', OrderStatus.pending)]);
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('عرض الطلب'));
      await tester.pumpAndSettle();

      expect(find.textContaining('طلب رقم 7'), findsOneWidget);
      expect(find.text('إلغاء الطلب'), findsOneWidget);
    });

    testWidgets('a delivered order sheet has no cancel button', (tester) async {
      await setPhoneViewport(tester);
      repository.ordersResult = Success([_order('7', OrderStatus.delivered)]);
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('عرض الطلب'));
      await tester.pumpAndSettle();

      expect(find.textContaining('طلب رقم 7'), findsOneWidget);
      expect(find.text('إلغاء الطلب'), findsNothing);
    });
  });
}
