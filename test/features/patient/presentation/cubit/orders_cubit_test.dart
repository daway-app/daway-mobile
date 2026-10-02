import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/order.dart';
import 'package:daway_app/features/patient/domain/repositories/orders_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/cancel_order_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_orders_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/orders_cubit.dart';
import 'package:daway_app/features/patient/presentation/cubit/orders_state.dart';
import 'package:flutter_test/flutter_test.dart';

final _order = Order(
  orderNumber: '1',
  pharmacyName: 'صيدلية الأمل',
  status: OrderStatus.confirmed,
  itemsCount: 1,
  price: 25,
  address: 'غزة',
  createdAt: DateTime(2026, 9, 29),
);

class _FakeOrdersRepository implements OrdersRepository {

  @override
  Future<ApiResult<void>> cancelOrder({required String token, required int orderId}) async =>
      const Success(null);
  ApiResult<List<Order>> ordersResult = Success([_order]);

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
  late _FakeOrdersRepository repository;

  OrdersCubit buildCubit() =>
      OrdersCubit(
        GetOrdersUseCase(repository, _FakeSessionRepository()),
        CancelOrderUseCase(repository, _FakeSessionRepository()),
      );

  setUp(() {
    repository = _FakeOrdersRepository();
  });

  test('loads the orders on construction', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<OrdersLoaded>());
    expect((cubit.state as OrdersLoaded).orders, [_order]);
  });

  test('cancel reloads the list and returns null on success', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    final error = await cubit.cancel(_order);

    expect(error, isNull);
    expect(cubit.state, isA<OrdersLoaded>());
  });

  test('surfaces a load failure', () async {
    repository.ordersResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<OrdersLoadFailure>());
  });

  test('load() refreshes the state after a failure', () async {
    repository.ordersResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    repository.ordersResult = Success([_order]);
    await cubit.load();

    expect(cubit.state, isA<OrdersLoaded>());
  });
}
