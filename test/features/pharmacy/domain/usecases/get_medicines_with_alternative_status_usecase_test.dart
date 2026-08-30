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
import 'package:flutter_test/flutter_test.dart';

const _available = Medicine(
  id: 1,
  medicineId: 11,
  name: 'Available',
  price: 10,
  quantity: 50,
  isAvailable: true,
);
const _lowNoAlternative = Medicine(
  id: 2,
  medicineId: 12,
  name: 'Low, no alternative yet',
  price: 10,
  quantity: 5,
  isAvailable: true,
);
const _outOfStockAlreadyHandled = Medicine(
  id: 3,
  medicineId: 13,
  name: 'Out of stock, already has an alternative',
  price: 10,
  quantity: 0,
  isAvailable: true,
);

class _FakeMedicineRepository implements PharmacyMedicineRepository {
  ApiResult<List<Medicine>> getResult = const Success([
    _available,
    _lowNoAlternative,
    _outOfStockAlreadyHandled,
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
  }) async => throw UnimplementedError();

  @override
  Future<ApiResult<List<MedicineCatalogItem>>> searchCatalog({
    required String token,
    required String query,
  }) async => throw UnimplementedError();
}

class _FakeAlternativesRepository implements PharmacyAlternativesRepository {
  ApiResult<Set<int>> withAlternativeResult = Success({
    _outOfStockAlreadyHandled.id,
  });

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
  late _FakeAlternativesRepository alternativesRepository;
  late GetMedicinesWithAlternativeStatusUseCase useCase;

  setUp(() {
    medicineRepository = _FakeMedicineRepository();
    alternativesRepository = _FakeAlternativesRepository();
    final sessionRepository = _FakeSessionRepository();
    useCase = GetMedicinesWithAlternativeStatusUseCase(
      GetPharmacyMedicinesUseCase(medicineRepository, sessionRepository),
      GetMedicineIdsWithAlternativeUseCase(
        alternativesRepository,
        sessionRepository,
      ),
    );
  });

  test(
    'returns every medicine, not just the ones needing an alternative',
    () async {
      final result = await useCase();

      expect(result, isA<Success<Object?>>());
      final data = (result as Success).data;
      expect(data.medicines, [
        _available,
        _lowNoAlternative,
        _outOfStockAlreadyHandled,
      ]);
    },
  );

  test(
    'alreadyHandledIds contains every medicine with a linked alternative',
    () async {
      final result = await useCase();

      final data = (result as Success).data;
      expect(data.alreadyHandledIds, {_outOfStockAlreadyHandled.id});
    },
  );

  test(
    'needingAlternativeIds is low/out-of-stock minus already-handled — not derived from the full list at the UI layer',
    () async {
      final result = await useCase();

      final data = (result as Success).data;
      expect(data.needingAlternativeIds, {_lowNoAlternative.id});
    },
  );

  test('surfaces a failure fetching the medicines list', () async {
    medicineRepository.getResult = const ApiError(
      NetworkFailure('تعذر الاتصال بالخادم'),
    );

    final result = await useCase();

    expect(result, isA<ApiError<Object?>>());
  });

  test(
    'a failure fetching which medicines already have an alternative degrades to empty sets, not a failed call',
    () async {
      alternativesRepository.withAlternativeResult = const ApiError(
        ApiFailure(message: 'failed'),
      );

      final result = await useCase();

      final data = (result as Success).data;
      expect(data.alreadyHandledIds, isEmpty);
      expect(data.needingAlternativeIds, {
        _lowNoAlternative.id,
        _outOfStockAlreadyHandled.id,
      });
    },
  );
}
