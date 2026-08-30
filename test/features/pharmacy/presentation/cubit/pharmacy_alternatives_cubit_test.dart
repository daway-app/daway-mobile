import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/alternatives_overview.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine_catalog_item.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_alternatives_repository.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_medicine_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_alternatives_overview_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_medicines_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/remove_alternative_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/select_alternative_usecase.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_alternatives_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_alternatives_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _baseMedicine = Medicine(
  id: 14,
  medicineId: 17,
  name: 'بندل',
  price: 40,
  quantity: 8,
  isAvailable: true,
);
const _candidateA = Medicine(
  id: 15,
  medicineId: 18,
  name: 'Clavamox',
  price: 23.5,
  quantity: 48,
  isAvailable: true,
);
const _candidateB = Medicine(
  id: 16,
  medicineId: 19,
  name: 'Moxclav',
  price: 22,
  quantity: 86,
  isAvailable: true,
);

class _FakeRepository implements PharmacyAlternativesRepository {
  ApiResult<AlternativesOverview> getResult = const Success(
    AlternativesOverview(
      baseMedicine: _baseMedicine,
      candidates: [_candidateA, _candidateB],
      selectedAlternativeIds: {},
    ),
  );
  ApiResult<void> selectResult = const Success(null);
  ApiResult<void> removeResult = const Success(null);
  int selectCallCount = 0;
  int removeCallCount = 0;
  int? lastAlternativeId;

  @override
  Future<ApiResult<AlternativesOverview>> getAlternativesOverview({
    required String token,
    required Medicine baseMedicine,
    required List<Medicine> allMedicines,
  }) async => getResult;

  @override
  Future<ApiResult<void>> selectAlternative({
    required String token,
    required int baseMedicineId,
    required int alternativeId,
  }) async {
    selectCallCount++;
    lastAlternativeId = alternativeId;
    return selectResult;
  }

  @override
  Future<ApiResult<void>> removeAlternative({
    required String token,
    required int baseMedicineId,
    required int alternativeId,
  }) async {
    removeCallCount++;
    lastAlternativeId = alternativeId;
    return removeResult;
  }

  @override
  Future<ApiResult<Set<int>>> getBaseMedicineIdsWithAlternatives({
    required String token,
  }) async => throw UnimplementedError();
}

class _FakeMedicineRepository implements PharmacyMedicineRepository {
  @override
  Future<ApiResult<List<Medicine>>> getMedicines({
    required String token,
  }) async => const Success([_baseMedicine, _candidateA, _candidateB]);

  @override
  Future<ApiResult<void>> addMedicine({
    required String token,
    int? medicineId,
    int? mohMedicineId,
    required double price,
    required int quantity,
    required bool isAvailable,
    String? imageUrl,
  }) async => throw UnimplementedError();

  @override
  Future<ApiResult<void>> addMedicineByName({
    required String token,
    required String tradeName,
    String? tradeNameAr,
    String? activeIngredient,
    required double price,
    required int quantity,
    required bool isAvailable,
    String? imageUrl,
  }) async => throw UnimplementedError();

  @override
  Future<ApiResult<void>> deleteMedicine({
    required String token,
    required int pharmacyMedicineId,
  }) async => throw UnimplementedError();

  @override
  Future<ApiResult<void>> updateMedicine({
    required String token,
    required int pharmacyMedicineId,
    required int medicineId,
    required double price,
    required int quantity,
    required bool isAvailable,
  }) async => throw UnimplementedError();

  @override
  Future<ApiResult<List<MedicineCatalogItem>>> searchCatalog({
    required String token,
    required String query,
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
  late _FakeRepository repository;
  late PharmacyAlternativesCubit cubit;

  setUp(() async {
    repository = _FakeRepository();
    final sessionRepository = _FakeSessionRepository();
    cubit = PharmacyAlternativesCubit(
      _baseMedicine,
      GetAlternativesOverviewUseCase(
        repository,
        GetPharmacyMedicinesUseCase(
          _FakeMedicineRepository(),
          sessionRepository,
        ),
        sessionRepository,
      ),
      SelectAlternativeUseCase(repository, sessionRepository),
      RemoveAlternativeUseCase(repository, sessionRepository),
    );
    await cubit.load();
  });

  tearDown(() => cubit.close());

  test('loads candidates and selection state on construction', () {
    final state = cubit.state as PharmacyAlternativesLoaded;
    expect(state.candidates, [_candidateA, _candidateB]);
    expect(state.selectedAlternativeIds, isEmpty);
  });

  test('surfaces a load failure', () async {
    repository.getResult = const ApiError(
      NetworkFailure('تعذر الاتصال بالخادم'),
    );

    await cubit.load();

    expect(cubit.state, isA<PharmacyAlternativesLoadFailure>());
  });

  test(
    'selecting a candidate with no previous selection only calls select, then reloads, returning null',
    () async {
      final error = await cubit.toggleCandidate(_candidateA);

      expect(error, isNull);
      expect(repository.selectCallCount, 1);
      expect(repository.removeCallCount, 0);
      final state = cubit.state as PharmacyAlternativesLoaded;
      expect(state.updatingCandidateId, isNull);
    },
  );

  test(
    'reload after a successful toggle keeps the list on screen instead of flashing to a spinner',
    () async {
      // Regression check for the "blank whole list on every reload" bug this
      // cubit's load() deliberately avoids for an already-loaded state.
      final statesSeen = <Type>[];
      final subscription = cubit.stream.listen(
        (state) => statesSeen.add(state.runtimeType),
      );

      await cubit.toggleCandidate(_candidateA);
      await subscription.cancel();

      expect(statesSeen, isNot(contains(PharmacyAlternativesLoading)));
    },
  );

  test(
    'selecting a different candidate removes the previous selection first',
    () async {
      repository.getResult = Success(
        AlternativesOverview(
          baseMedicine: _baseMedicine,
          candidates: const [_candidateA, _candidateB],
          // selectedAlternativeIds holds catalog ids (medicineId), not
          // pharmacy_medicine ids (id) — confirmed live, see
          // PharmacyAlternativesRepositoryImpl's doc comment.
          selectedAlternativeIds: {_candidateA.medicineId},
        ),
      );
      await cubit.load();

      await cubit.toggleCandidate(_candidateB);

      expect(repository.removeCallCount, 1);
      expect(repository.selectCallCount, 1);
    },
  );

  test('tapping the already-selected candidate only removes it', () async {
    repository.getResult = Success(
      AlternativesOverview(
        baseMedicine: _baseMedicine,
        candidates: const [_candidateA, _candidateB],
        selectedAlternativeIds: {_candidateA.medicineId},
      ),
    );
    await cubit.load();

    await cubit.toggleCandidate(_candidateA);

    expect(repository.removeCallCount, 1);
    expect(repository.selectCallCount, 0);
  });

  test(
    'a second tap on the same candidate while its request is in flight is ignored',
    () async {
      final firstToggle = cubit.toggleCandidate(_candidateA);
      await cubit.toggleCandidate(
        _candidateA,
      ); // should be a no-op — already updating

      await firstToggle;

      expect(repository.selectCallCount, 1);
    },
  );

  test(
    'tapping a DIFFERENT candidate while another is in flight is also ignored '
    '(backend allows multiple links, so this app enforces exclusivity client-side)',
    () async {
      final firstToggle = cubit.toggleCandidate(_candidateA);
      await cubit.toggleCandidate(_candidateB); // should be a no-op too

      await firstToggle;

      expect(repository.selectCallCount, 1);
    },
  );

  test(
    'a failed toggle returns the error message for a snackbar, then resyncs from the server',
    () async {
      repository.selectResult = const ApiError(
        ApiFailure(message: 'فشل الإضافة'),
      );

      final error = await cubit.toggleCandidate(_candidateA);

      expect(error, 'فشل الإضافة');
      final state = cubit.state as PharmacyAlternativesLoaded;
      // The reload after the failure resyncs from the server — this is the
      // fix for a partial failure (remove succeeds, the follow-up select
      // fails) leaving a stale local selection: the cubit always reloads on
      // ApiError, not just success.
      expect(state.updatingCandidateId, isNull);
      expect(state.candidates, [_candidateA, _candidateB]);
    },
  );
}
