import 'dart:async';

import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/pharmacy_dashboard_stats.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_dashboard_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_dashboard_stats_usecase.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_dashboard_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_dashboard_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _stats = PharmacyDashboardStats(
  totalMedicines: 10,
  availableCount: 8,
  lowStockCount: 1,
  outOfStockCount: 1,
  newInquiriesCount: 3,
  averageRating: 4.5,
  ratingsCount: 2,
  lowStockItems: [],
  recentInquiries: [],
);

const _newerStats = PharmacyDashboardStats(
  totalMedicines: 11,
  availableCount: 9,
  lowStockCount: 1,
  outOfStockCount: 1,
  newInquiriesCount: 3,
  averageRating: 4.5,
  ratingsCount: 2,
  lowStockItems: [],
  recentInquiries: [],
);

class _FakePharmacyDashboardRepository implements PharmacyDashboardRepository {
  ApiResult<PharmacyDashboardStats> getResult = const Success(_stats);
  int fetches = 0;

  /// When set, a fetch waits for it — keeps a load in flight for as long as a
  /// test needs.
  Completer<void>? gate;

  @override
  Future<ApiResult<PharmacyDashboardStats>> getDashboardStats({
    required String token,
  }) async {
    fetches++;
    final pending = gate;
    if (pending != null) await pending.future;
    return getResult;
  }
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession = const UserSession(
    accountType: AccountType.pharmacy,
    token: 'tok-1',
  );

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
  late _FakePharmacyDashboardRepository repository;
  late PharmacyDashboardCubit cubit;

  setUp(() async {
    repository = _FakePharmacyDashboardRepository();
    cubit = PharmacyDashboardCubit(
      GetPharmacyDashboardStatsUseCase(repository, _FakeSessionRepository()),
    );
    await cubit.load();
  });

  tearDown(() => cubit.close());

  test('loads dashboard stats on construction', () {
    final state = cubit.state as PharmacyDashboardLoaded;
    expect(state.stats.totalMedicines, 10);
    expect(state.stats.newInquiriesCount, 3);
    expect(state.stats.averageRating, 4.5);
  });

  test('surfaces a load failure', () async {
    repository.getResult = const ApiError(
      NetworkFailure('تعذر الاتصال بالخادم'),
    );

    await cubit.load();

    expect(cubit.state, isA<PharmacyDashboardLoadFailure>());
  });

  test('load() can retry and recover after a failure', () async {
    repository.getResult = const ApiError(
      NetworkFailure('تعذر الاتصال بالخادم'),
    );
    await cubit.load();
    expect(cubit.state, isA<PharmacyDashboardLoadFailure>());

    repository.getResult = const Success(_stats);
    await cubit.load();

    expect(cubit.state, isA<PharmacyDashboardLoaded>());
  });

  group('refresh()', () {
    test('swaps in the new figures without going back to loading', () async {
      final emitted = <PharmacyDashboardState>[];
      final subscription = cubit.stream.listen(emitted.add);
      addTearDown(subscription.cancel);
      repository.getResult = const Success(_newerStats);

      await cubit.refresh();
      await Future<void>.delayed(Duration.zero); // let the stream deliver

      expect(emitted.length, 1);
      expect(emitted.single, isA<PharmacyDashboardLoaded>());
      expect((cubit.state as PharmacyDashboardLoaded).stats.totalMedicines, 11);
    });

    test('keeps the figures on screen when the fetch fails', () async {
      final emitted = <PharmacyDashboardState>[];
      final subscription = cubit.stream.listen(emitted.add);
      addTearDown(subscription.cancel);
      repository.getResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));

      await cubit.refresh();
      await Future<void>.delayed(Duration.zero); // let the stream deliver

      expect(emitted, isEmpty);
      expect((cubit.state as PharmacyDashboardLoaded).stats.totalMedicines, 10);
    });

    test('retries a load that had failed', () async {
      repository.getResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
      await cubit.load();
      expect(cubit.state, isA<PharmacyDashboardLoadFailure>());

      repository.getResult = const Success(_newerStats);
      await cubit.refresh();

      expect((cubit.state as PharmacyDashboardLoaded).stats.totalMedicines, 11);
    });

    test('leaves a load that is still on its way to finish, without a second fetch', () async {
      final slowRepository = _FakePharmacyDashboardRepository()..gate = Completer<void>();
      final slowCubit = PharmacyDashboardCubit(
        GetPharmacyDashboardStatsUseCase(slowRepository, _FakeSessionRepository()),
      );
      addTearDown(slowCubit.close);
      await Future<void>.delayed(Duration.zero);
      expect(slowCubit.state, isA<PharmacyDashboardLoading>());
      final fetchesBefore = slowRepository.fetches;

      await slowCubit.refresh();

      expect(slowRepository.fetches, fetchesBefore);
      expect(slowCubit.state, isA<PharmacyDashboardLoading>());
      slowRepository.gate!.complete();
    });
  });
}
