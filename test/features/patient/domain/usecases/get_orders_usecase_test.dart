import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/order.dart';
import 'package:daway_app/features/patient/domain/repositories/orders_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_orders_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOrdersRepository implements OrdersRepository {

  @override
  Future<ApiResult<void>> cancelOrder({required String token, required int orderId}) async =>
      const Success(null);
  ApiResult<List<Order>> ordersResult = const Success([]);
  String? lastToken;

  @override
  Future<ApiResult<List<Order>>> getOrders({required String token}) async {
    lastToken = token;
    return ordersResult;
  }

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
  UserSession? savedSession;

  @override
  Future<void> saveSession(UserSession session) async => savedSession = session;

  @override
  Future<UserSession?> getSession() async => savedSession;

  @override
  Future<void> clearSession() async => savedSession = null;
}

void main() {
  test('passes the session token through to the repository', () async {
    final repository = _FakeOrdersRepository();
    final sessionRepository = _FakeSessionRepository()
      ..savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');
    final useCase = GetOrdersUseCase(repository, sessionRepository);

    final result = await useCase();

    expect(repository.lastToken, 'tok-1');
    expect(result, isA<Success<Object?>>());
  });

  test('returns a session failure without calling the repository when logged out', () async {
    final repository = _FakeOrdersRepository();
    final useCase = GetOrdersUseCase(repository, _FakeSessionRepository());

    final result = await useCase();

    expect(result, isA<ApiError<Object?>>());
    expect(repository.lastToken, isNull);
  });
}
