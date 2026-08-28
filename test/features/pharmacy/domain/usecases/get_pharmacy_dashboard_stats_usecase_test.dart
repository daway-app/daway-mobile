import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/pharmacy_dashboard_stats.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_dashboard_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_dashboard_stats_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

const _stats = PharmacyDashboardStats(
  totalMedicines: 10,
  availableCount: 8,
  lowStockCount: 1,
  outOfStockCount: 1,
  newInquiriesCount: 0,
  averageRating: 4.5,
  ratingsCount: 2,
  lowStockItems: [],
  recentInquiries: [],
);

class _FakePharmacyDashboardRepository implements PharmacyDashboardRepository {
  String? lastToken;
  ApiResult<PharmacyDashboardStats> getResult = const Success(_stats);

  @override
  Future<ApiResult<PharmacyDashboardStats>> getDashboardStats({
    required String token,
  }) async {
    lastToken = token;
    return getResult;
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
  late _FakePharmacyDashboardRepository repository;
  late _FakeSessionRepository sessionRepository;
  late GetPharmacyDashboardStatsUseCase useCase;

  setUp(() {
    repository = _FakePharmacyDashboardRepository();
    sessionRepository = _FakeSessionRepository();
    useCase = GetPharmacyDashboardStatsUseCase(repository, sessionRepository);
  });

  test(
    'fails without hitting the repository when there is no saved session',
    () async {
      final result = await useCase();

      expect(result, isA<ApiError<PharmacyDashboardStats>>());
      expect(repository.lastToken, isNull);
    },
  );

  test('fetches dashboard stats using the saved session token', () async {
    sessionRepository.savedSession = const UserSession(
      accountType: AccountType.pharmacy,
      token: 'tok-1',
    );

    final result = await useCase();

    expect(result, isA<Success<PharmacyDashboardStats>>());
    expect(repository.lastToken, 'tok-1');
  });

  test('surfaces a repository failure', () async {
    sessionRepository.savedSession = const UserSession(
      accountType: AccountType.pharmacy,
      token: 'tok-1',
    );
    repository.getResult = const ApiError(
      NetworkFailure('لا يوجد اتصال بالإنترنت'),
    );

    final result = await useCase();

    expect(result, isA<ApiError<PharmacyDashboardStats>>());
  });
}
