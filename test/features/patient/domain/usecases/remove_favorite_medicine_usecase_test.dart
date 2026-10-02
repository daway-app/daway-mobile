import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/favorite_medicine.dart';
import 'package:daway_app/features/patient/domain/repositories/favorites_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/remove_favorite_medicine_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFavoritesRepository implements FavoritesRepository {
  ApiResult<void> removeResult = const Success(null);
  String? lastToken;
  int? lastMedicineId;

  @override
  Future<ApiResult<List<FavoriteMedicine>>> getFavoriteMedicines({required String token}) async =>
      const Success([]);

  @override
  Future<ApiResult<void>> addFavoriteMedicine({
    required String token,
    required int medicineId,
  }) async =>
      const Success(null);

  @override
  Future<ApiResult<void>> removeFavoriteMedicine({
    required String token,
    required int medicineId,
  }) async {
    lastToken = token;
    lastMedicineId = medicineId;
    return removeResult;
  }
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession;

  @override
  Future<void> saveSession(UserSession session) async {
    savedSession = session;
  }

  @override
  Future<UserSession?> getSession() async => savedSession;

  @override
  Future<void> clearSession() async {
    savedSession = null;
  }
}

void main() {
  test('passes the session token and medicine id through to the repository', () async {
    final repository = _FakeFavoritesRepository();
    final sessionRepository = _FakeSessionRepository()
      ..savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');
    final useCase = RemoveFavoriteMedicineUseCase(repository, sessionRepository);

    final result = await useCase(1);

    expect(repository.lastToken, 'tok-1');
    expect(repository.lastMedicineId, 1);
    expect(result, isA<Success<void>>());
  });

  test('returns a session failure without calling the repository when logged out', () async {
    final repository = _FakeFavoritesRepository();
    final sessionRepository = _FakeSessionRepository();
    final useCase = RemoveFavoriteMedicineUseCase(repository, sessionRepository);

    final result = await useCase(1);

    expect(result, isA<ApiError<void>>());
    expect(repository.lastMedicineId, isNull);
  });

  test('surfaces a repository failure unchanged', () async {
    final repository = _FakeFavoritesRepository()
      ..removeResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final sessionRepository = _FakeSessionRepository()
      ..savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');
    final useCase = RemoveFavoriteMedicineUseCase(repository, sessionRepository);

    final result = await useCase(1);

    expect(result, isA<ApiError<void>>());
  });
}
