import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/cart_item.dart';
import 'package:daway_app/features/patient/domain/repositories/cart_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/update_cart_item_quantity_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCartRepository implements CartRepository {

  @override
  Future<ApiResult<void>> deleteItem({required String token, required int itemId}) async =>
      const Success(null);

  @override
  Future<ApiResult<void>> clearCart({required String token}) async => const Success(null);

  @override
  Future<ApiResult<void>> addItem({
    required String token,
    int? pharmacyMedicineId,
    required int pharmacyId,
    required int medicineId,
    required int quantity,
  }) async =>
      const Success(null);
  ApiResult<void> updateResult = const Success(null);
  String? lastToken;
  int? lastItemId;
  int? lastQuantity;

  @override
  Future<ApiResult<List<CartItem>>> getItems({required String token}) async => const Success([]);

  @override
  Future<ApiResult<void>> updateQuantity({
    required String token,
    required int itemId,
    required int quantity,
  }) async {
    lastToken = token;
    lastItemId = itemId;
    lastQuantity = quantity;
    return updateResult;
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
  test('passes the session token, item id and quantity through to the repository', () async {
    final repository = _FakeCartRepository();
    final sessionRepository = _FakeSessionRepository()
      ..savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');
    final useCase = UpdateCartItemQuantityUseCase(repository, sessionRepository);

    final result = await useCase(itemId: 7, quantity: 3);

    expect(repository.lastToken, 'tok-1');
    expect(repository.lastItemId, 7);
    expect(repository.lastQuantity, 3);
    expect(result, isA<Success<void>>());
  });

  test('returns a session failure without calling the repository when logged out', () async {
    final repository = _FakeCartRepository();
    final useCase = UpdateCartItemQuantityUseCase(repository, _FakeSessionRepository());

    final result = await useCase(itemId: 7, quantity: 3);

    expect(result, isA<ApiError<void>>());
    expect(repository.lastItemId, isNull);
  });

  test('surfaces a repository failure unchanged', () async {
    final repository = _FakeCartRepository()
      ..updateResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final sessionRepository = _FakeSessionRepository()
      ..savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');
    final useCase = UpdateCartItemQuantityUseCase(repository, sessionRepository);

    final result = await useCase(itemId: 7, quantity: 3);

    expect(result, isA<ApiError<void>>());
  });
}
