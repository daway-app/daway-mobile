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

class _FakePharmacyDashboardRepository implements PharmacyDashboardRepository {
  ApiResult<PharmacyDashboardStats> getResult = const Success(_stats);

  @override
  Future<ApiResult<PharmacyDashboardStats>> getDashboardStats({
    required String token,
  }) async => getResult;
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
}
