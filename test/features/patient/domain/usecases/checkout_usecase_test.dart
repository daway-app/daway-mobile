import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/order.dart';
import 'package:daway_app/features/patient/domain/repositories/orders_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/checkout_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOrdersRepository implements OrdersRepository {

  @override
  Future<ApiResult<void>> cancelOrder({required String token, required int orderId}) async =>
      const Success(null);
  ApiResult<int> checkoutResult = const Success(1);
  String? lastToken;
  int? lastAddressId;
  String? lastCouponCode;

  @override
  Future<ApiResult<List<Order>>> getOrders({required String token}) async => const Success([]);

  @override
  Future<ApiResult<int>> checkout({
    required String token,
    required int addressId,
    String? couponCode,
    String? notes,
  }) async {
    lastToken = token;
    lastAddressId = addressId;
    lastCouponCode = couponCode;
    return checkoutResult;
  }
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
  test('passes the session token, address id and coupon through to the repository', () async {
    final repository = _FakeOrdersRepository();
    final sessionRepository = _FakeSessionRepository()
      ..savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');
    final useCase = CheckoutUseCase(repository, sessionRepository);

    final result = await useCase(addressId: 1, couponCode: 'SAVE20');

    expect(repository.lastToken, 'tok-1');
    expect(repository.lastAddressId, 1);
    expect(repository.lastCouponCode, 'SAVE20');
    expect(result, isA<Success<int>>());
  });

  test('returns a session failure without calling the repository when logged out', () async {
    final repository = _FakeOrdersRepository();
    final useCase = CheckoutUseCase(repository, _FakeSessionRepository());

    final result = await useCase(addressId: 1);

    expect(result, isA<ApiError<int>>());
    expect(repository.lastAddressId, isNull);
  });

  test('surfaces a repository failure (e.g. empty cart) unchanged', () async {
    final repository = _FakeOrdersRepository()
      ..checkoutResult = const ApiError(ApiFailure(message: 'السلة فارغة'));
    final sessionRepository = _FakeSessionRepository()
      ..savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');
    final useCase = CheckoutUseCase(repository, sessionRepository);

    final result = await useCase(addressId: 1);

    expect(result, isA<ApiError<int>>());
  });
}
