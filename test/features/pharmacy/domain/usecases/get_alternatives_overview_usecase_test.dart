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
import 'package:flutter_test/flutter_test.dart';

const _baseMedicine = Medicine(
  id: 14,
  medicineId: 17,
  name: 'بندل',
  price: 40,
  quantity: 8,
  isAvailable: true,
);
const _stockList = [_baseMedicine];

const _overview = AlternativesOverview(
  baseMedicine: _baseMedicine,
  candidates: [],
  selectedAlternativeIds: {},
);

class _FakePharmacyAlternativesRepository
    implements PharmacyAlternativesRepository {
  String? lastToken;
  List<Medicine>? lastAllMedicines;
  ApiResult<AlternativesOverview> getResult = const Success(_overview);

  @override
  Future<ApiResult<AlternativesOverview>> getAlternativesOverview({
    required String token,
    required Medicine baseMedicine,
    required List<Medicine> allMedicines,
  }) async {
    lastToken = token;
    lastAllMedicines = allMedicines;
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
  Future<ApiResult<Set<int>>> getBaseMedicineIdsWithAlternatives({
    required String token,
  }) async => throw UnimplementedError();
}

class _FakePharmacyMedicineRepository implements PharmacyMedicineRepository {
  ApiResult<List<Medicine>> getResult = const Success(_stockList);

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
    required String tradeName,
    String? tradeNameAr,
    String? activeIngredient,
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
  late _FakePharmacyMedicineRepository medicineRepository;
  late _FakeSessionRepository sessionRepository;
  late GetAlternativesOverviewUseCase useCase;

  setUp(() {
    repository = _FakePharmacyAlternativesRepository();
    medicineRepository = _FakePharmacyMedicineRepository();
    sessionRepository = _FakeSessionRepository();
    useCase = GetAlternativesOverviewUseCase(
      repository,
      GetPharmacyMedicinesUseCase(medicineRepository, sessionRepository),
      sessionRepository,
    );
  });

  test(
    'fails without hitting the repository when there is no saved session',
    () async {
      final result = await useCase(_baseMedicine);

      expect(result, isA<ApiError<AlternativesOverview>>());
      expect(repository.lastToken, isNull);
    },
  );

  test(
    'fetches the overview using the saved session token and the full stock list',
    () async {
      sessionRepository.savedSession = const UserSession(
        accountType: AccountType.pharmacy,
        token: 'tok-1',
      );

      final result = await useCase(_baseMedicine);

      expect(result, isA<Success<AlternativesOverview>>());
      expect(repository.lastToken, 'tok-1');
      expect(repository.lastAllMedicines, _stockList);
    },
  );

  test('surfaces a repository failure', () async {
    sessionRepository.savedSession = const UserSession(
      accountType: AccountType.pharmacy,
      token: 'tok-1',
    );
    repository.getResult = const ApiError(
      NetworkFailure('لا يوجد اتصال بالإنترنت'),
    );

    final result = await useCase(_baseMedicine);

    expect(result, isA<ApiError<AlternativesOverview>>());
  });

  test(
    'a failure fetching the full stock list fails the call without hitting the alternatives repository',
    () async {
      sessionRepository.savedSession = const UserSession(
        accountType: AccountType.pharmacy,
        token: 'tok-1',
      );
      medicineRepository.getResult = const ApiError(
        NetworkFailure('تعذر الاتصال بالخادم'),
      );

      final result = await useCase(_baseMedicine);

      expect(result, isA<ApiError<AlternativesOverview>>());
      expect(repository.lastToken, isNull);
    },
  );
}
