import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/alternatives_overview.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_alternatives_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_medicine_ids_with_alternative_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements PharmacyAlternativesRepository {
  String? lastToken;
  ApiResult<Set<int>> getResult = const Success({14, 22});

  @override
  Future<ApiResult<Set<int>>> getBaseMedicineIdsWithAlternatives({
    required String token,
  }) async {
    lastToken = token;
    return getResult;
  }

  @override
  Future<ApiResult<void>> selectAlternative({
    required String token,
    required int baseMedicineId,
    required int alternativeId,
  }) async => throw UnimplementedError();

  @override
  Future<ApiResult<void>> removeAlternative({
    required String token,
    required int baseMedicineId,
    required int alternativeId,
  }) async => throw UnimplementedError();

  @override
  Future<ApiResult<AlternativesOverview>> getAlternativesOverview({
    required String token,
    required Medicine baseMedicine,
    required List<Medicine> allMedicines,
  }) async => throw UnimplementedError();
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
  late _FakeRepository repository;
  late _FakeSessionRepository sessionRepository;
  late GetMedicineIdsWithAlternativeUseCase useCase;

  setUp(() {
    repository = _FakeRepository();
    sessionRepository = _FakeSessionRepository();
    useCase = GetMedicineIdsWithAlternativeUseCase(
      repository,
      sessionRepository,
    );
  });

  test(
    'fails without hitting the repository when there is no saved session',
    () async {
      final result = await useCase();

      expect(result, isA<ApiError<Set<int>>>());
      expect(repository.lastToken, isNull);
    },
  );

  test('fetches the set using the saved session token', () async {
    sessionRepository.savedSession = const UserSession(
      accountType: AccountType.pharmacy,
      token: 'tok-1',
    );

    final result = await useCase();

    expect(result, isA<Success<Set<int>>>());
    expect((result as Success).data, {14, 22});
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

    expect(result, isA<ApiError<Set<int>>>());
  });
}
