import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/domain/entities/favorite_medicine.dart';
import 'package:daway_app/features/patient/domain/repositories/favorites_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_favorite_medicines_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFavoritesRepository implements FavoritesRepository {
  ApiResult<List<FavoriteMedicine>> result = const Success([]);
  String? lastToken;

  @override
  Future<ApiResult<List<FavoriteMedicine>>> getFavoriteMedicines({required String token}) async {
    lastToken = token;
    return result;
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
  test('passes the session token through to the repository', () async {
    final repository = _FakeFavoritesRepository();
    repository.result = const Success([
      FavoriteMedicine(medicineId: 1, tradeName: 'Panadol', isAvailable: true, pharmaciesCount: 1),
    ]);
    final sessionRepository = _FakeSessionRepository()
      ..savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');
    final useCase = GetFavoriteMedicinesUseCase(repository, sessionRepository);

    final result = await useCase();

    expect(repository.lastToken, 'tok-1');
    expect(result, isA<Success<List<FavoriteMedicine>>>());
    expect((result as Success).data.single.tradeName, 'Panadol');
  });

  test('returns a session failure without calling the repository when logged out', () async {
    final repository = _FakeFavoritesRepository();
    final sessionRepository = _FakeSessionRepository();
    final useCase = GetFavoriteMedicinesUseCase(repository, sessionRepository);

    final result = await useCase();

    expect(result, isA<ApiError<List<FavoriteMedicine>>>());
    expect(repository.lastToken, isNull);
  });

  test('surfaces a repository failure unchanged', () async {
    final repository = _FakeFavoritesRepository();
    repository.result = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final sessionRepository = _FakeSessionRepository()
      ..savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');
    final useCase = GetFavoriteMedicinesUseCase(repository, sessionRepository);

    final result = await useCase();

    expect(result, isA<ApiError<List<FavoriteMedicine>>>());
  });
}
