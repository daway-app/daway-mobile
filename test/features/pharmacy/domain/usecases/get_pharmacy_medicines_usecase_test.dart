import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine_catalog_item.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_medicine_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_medicines_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

const _medicine = Medicine(
  id: 1,
  medicineId: 5,
  name: 'Panadol',
  activeIngredient: 'Paracetamol 500mg',
  price: 25,
  quantity: 120,
  isAvailable: true,
);

class _FakePharmacyMedicineRepository implements PharmacyMedicineRepository {
  String? lastToken;
  ApiResult<List<Medicine>> getResult = const Success([_medicine]);

  @override
  Future<ApiResult<List<Medicine>>> getMedicines({required String token}) async {
    lastToken = token;
    return getResult;
  }

  @override
  Future<ApiResult<List<MedicineCatalogItem>>> searchCatalog({
    required String token,
    required String query,
  }) async {
    throw UnimplementedError();
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
  }) async {
    throw UnimplementedError();
  }

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
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<void>> deleteMedicine({
    required String token,
    required int pharmacyMedicineId,
  }) async {
    throw UnimplementedError();
  }

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
  }) async {
    throw UnimplementedError();
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
  late _FakePharmacyMedicineRepository repository;
  late _FakeSessionRepository sessionRepository;
  late GetPharmacyMedicinesUseCase useCase;

  setUp(() {
    repository = _FakePharmacyMedicineRepository();
    sessionRepository = _FakeSessionRepository();
    useCase = GetPharmacyMedicinesUseCase(repository, sessionRepository);
  });

  test('fails without hitting the repository when there is no saved session', () async {
    final result = await useCase();

    expect(result, isA<ApiError<List<Medicine>>>());
    expect(repository.lastToken, isNull);
  });

  test('fetches medicines using the saved session token', () async {
    sessionRepository.savedSession =
        const UserSession(accountType: AccountType.pharmacy, token: 'tok-1');

    final result = await useCase();

    expect(result, isA<Success<List<Medicine>>>());
    expect(repository.lastToken, 'tok-1');
  });

  test('surfaces a repository failure', () async {
    sessionRepository.savedSession =
        const UserSession(accountType: AccountType.pharmacy, token: 'tok-1');
    repository.getResult = const ApiError(NetworkFailure('لا يوجد اتصال بالإنترنت'));

    final result = await useCase();

    expect(result, isA<ApiError<List<Medicine>>>());
  });
}
