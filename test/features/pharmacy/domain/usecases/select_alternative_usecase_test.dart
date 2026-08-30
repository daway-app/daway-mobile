import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/alternatives_overview.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_alternatives_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/select_alternative_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePharmacyAlternativesRepository
    implements PharmacyAlternativesRepository {
  final List<String> calls = [];
  ApiResult<void> selectResult = const Success(null);
  ApiResult<void> removeResult = const Success(null);

  @override
  Future<ApiResult<void>> selectAlternative({
    required String token,
    required int baseMedicineId,
    required int alternativeId,
  }) async {
    calls.add('select($baseMedicineId, $alternativeId)');
    return selectResult;
  }

  @override
  Future<ApiResult<void>> removeAlternative({
    required String token,
    required int baseMedicineId,
    required int alternativeId,
  }) async {
    calls.add('remove($baseMedicineId, $alternativeId)');
    return removeResult;
  }

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
  late _FakePharmacyAlternativesRepository repository;
  late SelectAlternativeUseCase useCase;

  setUp(() {
    repository = _FakePharmacyAlternativesRepository();
    useCase = SelectAlternativeUseCase(repository, _FakeSessionRepository());
  });

  test(
    'only creates the new link when there is no previous selection',
    () async {
      final result = await useCase(
        baseMedicineId: 14,
        newAlternativeId: 16,
        previousAlternativeIds: const {},
      );

      expect(result, isA<Success<void>>());
      expect(repository.calls, ['select(14, 16)']);
    },
  );

  test(
    'removes the previous link before creating the new one when it differs',
    () async {
      final result = await useCase(
        baseMedicineId: 14,
        newAlternativeId: 16,
        previousAlternativeIds: const {12},
      );

      expect(result, isA<Success<void>>());
      expect(repository.calls, ['remove(14, 12)', 'select(14, 16)']);
    },
  );

  test(
    'removes every previously-selected id when more than one was linked (backend allows multiple)',
    () async {
      final result = await useCase(
        baseMedicineId: 14,
        newAlternativeId: 16,
        previousAlternativeIds: const {12, 13},
      );

      expect(result, isA<Success<void>>());
      expect(
        repository.calls,
        containsAll(['remove(14, 12)', 'remove(14, 13)']),
      );
      expect(repository.calls.last, 'select(14, 16)');
    },
  );

  test(
    'does not remove the "new" selection if it was already among the previous ones',
    () async {
      final result = await useCase(
        baseMedicineId: 14,
        newAlternativeId: 16,
        previousAlternativeIds: const {16},
      );

      expect(result, isA<Success<void>>());
      expect(repository.calls, ['select(14, 16)']);
    },
  );

  test(
    'stops and surfaces the failure without creating the new link if removing an old one fails',
    () async {
      repository.removeResult = const ApiError(
        ApiFailure(message: 'فشل الحذف'),
      );

      final result = await useCase(
        baseMedicineId: 14,
        newAlternativeId: 16,
        previousAlternativeIds: const {12},
      );

      expect(result, isA<ApiError<void>>());
      expect(repository.calls, ['remove(14, 12)']);
    },
  );

  test('surfaces a create failure', () async {
    repository.selectResult = const ApiError(
      ApiFailure(message: 'فشل الإضافة'),
    );

    final result = await useCase(
      baseMedicineId: 14,
      newAlternativeId: 16,
      previousAlternativeIds: const {},
    );

    expect(result, isA<ApiError<void>>());
  });
}
