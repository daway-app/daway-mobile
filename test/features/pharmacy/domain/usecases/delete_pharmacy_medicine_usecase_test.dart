import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine_catalog_item.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_medicine_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/delete_pharmacy_medicine_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePharmacyMedicineRepository implements PharmacyMedicineRepository {
  String? lastToken;
  int? lastPharmacyMedicineId;
  ApiResult<void> deleteResult = const Success(null);

  @override
  Future<ApiResult<List<Medicine>>> getMedicines({required String token}) async {
    throw UnimplementedError();
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
    lastToken = token;
    lastPharmacyMedicineId = pharmacyMedicineId;
    return deleteResult;
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
  late DeletePharmacyMedicineUseCase useCase;

  setUp(() {
    repository = _FakePharmacyMedicineRepository();
    sessionRepository = _FakeSessionRepository();
    useCase = DeletePharmacyMedicineUseCase(repository, sessionRepository);
  });

  test('fails without hitting the repository when there is no saved session', () async {
    final result = await useCase(1);

    expect(result, isA<ApiError<void>>());
    expect(repository.lastToken, isNull);
  });

  test('deletes the medicine using the saved session token', () async {
    sessionRepository.savedSession =
        const UserSession(accountType: AccountType.pharmacy, token: 'tok-1');

    final result = await useCase(7);

    expect(result, isA<Success<void>>());
    expect(repository.lastToken, 'tok-1');
    expect(repository.lastPharmacyMedicineId, 7);
  });

  test('surfaces a repository failure', () async {
    sessionRepository.savedSession =
        const UserSession(accountType: AccountType.pharmacy, token: 'tok-1');
    repository.deleteResult = const ApiError(ApiFailure(message: 'فشل الحذف'));

    final result = await useCase(7);

    expect(result, isA<ApiError<void>>());
  });
}
