import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/alternatives_overview.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_alternatives_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/remove_alternative_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePharmacyAlternativesRepository
    implements PharmacyAlternativesRepository {
  String? lastToken;
  int? lastBaseMedicineId;
  int? lastAlternativeId;
  ApiResult<void> removeResult = const Success(null);

  @override
  Future<ApiResult<void>> removeAlternative({
    required String token,
    required int baseMedicineId,
    required int alternativeId,
  }) async {
    lastToken = token;
    lastBaseMedicineId = baseMedicineId;
    lastAlternativeId = alternativeId;
    return removeResult;
  }

  @override
  Future<ApiResult<void>> selectAlternative({
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

  @override
  Future<ApiResult<Set<int>>> getBaseMedicineIdsWithAlternatives({
    required String token,
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
  late _FakePharmacyAlternativesRepository repository;
  late _FakeSessionRepository sessionRepository;
  late RemoveAlternativeUseCase useCase;

  setUp(() {
    repository = _FakePharmacyAlternativesRepository();
    sessionRepository = _FakeSessionRepository();
    useCase = RemoveAlternativeUseCase(repository, sessionRepository);
  });

  test(
    'fails without hitting the repository when there is no saved session',
    () async {
      final result = await useCase(baseMedicineId: 14, alternativeId: 16);

      expect(result, isA<ApiError<void>>());
      expect(repository.lastToken, isNull);
    },
  );

  test('removes the link using the saved session token', () async {
    sessionRepository.savedSession = const UserSession(
      accountType: AccountType.pharmacy,
      token: 'tok-1',
    );

    final result = await useCase(baseMedicineId: 14, alternativeId: 16);

    expect(result, isA<Success<void>>());
    expect(repository.lastToken, 'tok-1');
    expect(repository.lastBaseMedicineId, 14);
    expect(repository.lastAlternativeId, 16);
  });

  test('surfaces a repository failure', () async {
    sessionRepository.savedSession = const UserSession(
      accountType: AccountType.pharmacy,
      token: 'tok-1',
    );
    repository.removeResult = const ApiError(
      NetworkFailure('لا يوجد اتصال بالإنترنت'),
    );

    final result = await useCase(baseMedicineId: 14, alternativeId: 16);

    expect(result, isA<ApiError<void>>());
  });
}
