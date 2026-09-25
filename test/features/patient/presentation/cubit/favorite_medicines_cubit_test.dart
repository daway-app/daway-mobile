import 'dart:async';

import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/favorite_medicine.dart';
import 'package:daway_app/features/patient/domain/repositories/favorites_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_favorite_medicines_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/favorite_medicines_cubit.dart';
import 'package:daway_app/features/patient/presentation/cubit/favorite_medicines_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _favorites = [
  FavoriteMedicine(medicineId: 1, tradeName: 'Panadol', isAvailable: true, pharmaciesCount: 1),
];

class _FakeFavoritesRepository implements FavoritesRepository {
  ApiResult<List<FavoriteMedicine>> result = const Success(_favorites);

  @override
  Future<ApiResult<List<FavoriteMedicine>>> getFavoriteMedicines({required String token}) async =>
      result;
}

/// Answers only when the test completes it.
class _ControlledFavoritesRepository implements FavoritesRepository {
  final Completer<ApiResult<List<FavoriteMedicine>>> completer = Completer();

  @override
  Future<ApiResult<List<FavoriteMedicine>>> getFavoriteMedicines({required String token}) =>
      completer.future;
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession =
      const UserSession(accountType: AccountType.patient, token: 'tok-1');

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
  late _FakeFavoritesRepository repository;

  setUp(() {
    repository = _FakeFavoritesRepository();
  });

  test('loads the favorites on construction', () async {
    final cubit = FavoriteMedicinesCubit(
      GetFavoriteMedicinesUseCase(repository, _FakeSessionRepository()),
    );
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<FavoriteMedicinesLoaded>());
    expect((cubit.state as FavoriteMedicinesLoaded).medicines, _favorites);
  });

  test('surfaces a load failure', () async {
    repository.result = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = FavoriteMedicinesCubit(
      GetFavoriteMedicinesUseCase(repository, _FakeSessionRepository()),
    );
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<FavoriteMedicinesLoadFailure>());
    expect((cubit.state as FavoriteMedicinesLoadFailure).message, 'تعذر الاتصال بالخادم');
  });

  test('load() can be called again to retry after a failure', () async {
    repository.result = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = FavoriteMedicinesCubit(
      GetFavoriteMedicinesUseCase(repository, _FakeSessionRepository()),
    );
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, isA<FavoriteMedicinesLoadFailure>());

    repository.result = const Success(_favorites);
    await cubit.load();

    expect(cubit.state, isA<FavoriteMedicinesLoaded>());
  });

  test('closing while the request is in flight (the screen was popped) does not throw', () async {
    final controlled = _ControlledFavoritesRepository();
    final cubit = FavoriteMedicinesCubit(
      GetFavoriteMedicinesUseCase(controlled, _FakeSessionRepository()),
    );
    await Future<void>.delayed(Duration.zero);

    await cubit.close();
    controlled.completer.complete(const Success(_favorites));
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    // Reaching here means no uncaught "emit after close" error failed the test.
    expect(cubit.isClosed, isTrue);
  });
}
