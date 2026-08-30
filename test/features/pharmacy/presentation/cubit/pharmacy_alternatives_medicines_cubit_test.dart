import 'dart:async';

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
import 'package:daway_app/features/pharmacy/domain/usecases/get_medicine_ids_with_alternative_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_medicines_with_alternative_status_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_medicines_usecase.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_alternatives_medicines_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_alternatives_medicines_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _available = Medicine(
  id: 1,
  medicineId: 11,
  name: 'Available',
  price: 10,
  quantity: 50,
  isAvailable: true,
);
const _low = Medicine(
  id: 2,
  medicineId: 12,
  name: 'Low stock',
  activeIngredient: 'Amoxicillin',
  price: 10,
  quantity: 5,
  isAvailable: true,
);
const _outOfStock = Medicine(
  id: 3,
  medicineId: 13,
  name: 'دواء نافد',
  price: 10,
  quantity: 0,
  isAvailable: true,
);
const _hasArabicName = Medicine(
  id: 5,
  medicineId: 15,
  name: 'Augmentin',
  nameAr: 'أوجمنتين',
  price: 10,
  quantity: 40,
  isAvailable: true,
);

class _FakeMedicineRepository implements PharmacyMedicineRepository {
  ApiResult<List<Medicine>> getResult = const Success([
    _available,
    _low,
    _outOfStock,
    _hasArabicName,
  ]);

  @override
  Future<ApiResult<List<Medicine>>> getMedicines({
    required String token,
  }) async => getResult;

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
    required String tradeName,
    String? tradeNameAr,
    String? activeIngredient,
  }) async => throw UnimplementedError();

  @override
  Future<ApiResult<List<MedicineCatalogItem>>> searchCatalog({
    required String token,
    required String query,
  }) async => throw UnimplementedError();
}

class _FakeAlternativesRepository implements PharmacyAlternativesRepository {
  ApiResult<Set<int>> withAlternativeResult = const Success({});

  @override
  Future<ApiResult<Set<int>>> getBaseMedicineIdsWithAlternatives({
    required String token,
  }) async => withAlternativeResult;

  @override
  Future<ApiResult<AlternativesOverview>> getAlternativesOverview({
    required String token,
    required Medicine baseMedicine,
    required List<Medicine> allMedicines,
  }) async => throw UnimplementedError();

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
  late _FakeMedicineRepository medicineRepository;
  late PharmacyAlternativesMedicinesCubit cubit;

  PharmacyAlternativesMedicinesCubit buildCubit({
    _FakeMedicineRepository? medicineRepo,
    _FakeAlternativesRepository? alternativesRepo,
  }) {
    final sessionRepository = _FakeSessionRepository();
    return PharmacyAlternativesMedicinesCubit(
      GetMedicinesWithAlternativeStatusUseCase(
        GetPharmacyMedicinesUseCase(
          medicineRepo ?? _FakeMedicineRepository(),
          sessionRepository,
        ),
        GetMedicineIdsWithAlternativeUseCase(
          alternativesRepo ?? _FakeAlternativesRepository(),
          sessionRepository,
        ),
      ),
    );
  }

  setUp(() async {
    medicineRepository = _FakeMedicineRepository();
    cubit = buildCubit(medicineRepo: medicineRepository);
    // The cubit's constructor already kicks off a load(); wait for it.
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() => cubit.close());

  test('loads every medicine, not just ones needing an alternative', () {
    final state = cubit.state as PharmacyAlternativesMedicinesLoaded;
    expect(state.medicines, [_available, _low, _outOfStock, _hasArabicName]);
    expect(state.needingAlternativeIds, {_low.id, _outOfStock.id});
    expect(state.alreadyHandledIds, isEmpty);
  });

  test('surfaces a load failure', () async {
    medicineRepository.getResult = const ApiError(
      NetworkFailure('تعذر الاتصال بالخادم'),
    );

    await cubit.load();

    expect(cubit.state, isA<PharmacyAlternativesMedicinesLoadFailure>());
  });

  test('queryChanged narrows the list by name or active ingredient', () {
    cubit.queryChanged('Amox');

    final state = cubit.state as PharmacyAlternativesMedicinesLoaded;
    expect(state.filteredMedicines, [_low]);
  });

  test(
    'queryChanged also matches the raw English name when an Arabic name is set',
    () {
      // Regression check: a medicine's displayName prefers nameAr when set,
      // so searching by the raw English trade name must fall back to
      // checking `name` directly instead of only `displayName`.
      cubit.queryChanged('Augmentin');

      final state = cubit.state as PharmacyAlternativesMedicinesLoaded;
      expect(state.filteredMedicines, [_hasArabicName]);
    },
  );

  test('queryChanged is a no-op before the first load completes', () async {
    final loadingCubit = buildCubit();
    loadingCubit.queryChanged('anything');
    expect(loadingCubit.state, isA<PharmacyAlternativesMedicinesLoading>());
    await loadingCubit.close();
  });

  test(
    'reload after returning from picking an alternative preserves the search query',
    () async {
      cubit.queryChanged('نافد');

      await cubit.load();

      final state = cubit.state as PharmacyAlternativesMedicinesLoaded;
      expect(state.query, 'نافد');
      expect(state.filteredMedicines, [_outOfStock]);
    },
  );

  test(
    'a query typed while a reload is in flight is not reverted once the reload resolves',
    () async {
      // Only the SECOND getMedicines() call (the explicit reload below)
      // blocks — the cubit's own constructor-triggered initial load must
      // resolve immediately so state is already Loaded (and queryChanged
      // is no longer a no-op) by the time the reload starts.
      final completer = Completer<void>();
      final delayedRepo = _DelayedMedicineRepository(completer);
      final sessionRepository = _FakeSessionRepository();
      final delayedCubit = PharmacyAlternativesMedicinesCubit(
        GetMedicinesWithAlternativeStatusUseCase(
          GetPharmacyMedicinesUseCase(delayedRepo, sessionRepository),
          GetMedicineIdsWithAlternativeUseCase(
            _FakeAlternativesRepository(),
            sessionRepository,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(delayedCubit.state, isA<PharmacyAlternativesMedicinesLoaded>());

      final reload = delayedCubit.load();
      delayedCubit.queryChanged('نافد');

      completer.complete();
      await reload;

      final state = delayedCubit.state as PharmacyAlternativesMedicinesLoaded;
      expect(state.query, 'نافد');
      await delayedCubit.close();
    },
  );

  test(
    'reload keeps the list on screen instead of flashing to a spinner',
    () async {
      final statesSeen = <Type>[];
      final subscription = cubit.stream.listen(
        (state) => statesSeen.add(state.runtimeType),
      );

      await cubit.load();
      await subscription.cancel();

      expect(statesSeen, isNot(contains(PharmacyAlternativesMedicinesLoading)));
    },
  );
}

class _DelayedMedicineRepository implements PharmacyMedicineRepository {
  final Completer<void> _completer;
  int _callCount = 0;

  _DelayedMedicineRepository(this._completer);

  @override
  Future<ApiResult<List<Medicine>>> getMedicines({
    required String token,
  }) async {
    _callCount++;
    // Only the second call (the explicit reload under test) waits — the
    // cubit's own constructor-triggered first load must resolve
    // immediately.
    if (_callCount >= 2) await _completer.future;
    return const Success([_available, _low, _outOfStock, _hasArabicName]);
  }

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
    required String tradeName,
    String? tradeNameAr,
    String? activeIngredient,
  }) async => throw UnimplementedError();

  @override
  Future<ApiResult<List<MedicineCatalogItem>>> searchCatalog({
    required String token,
    required String query,
  }) async => throw UnimplementedError();
}
