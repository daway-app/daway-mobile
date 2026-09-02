import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine_catalog_item.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_medicine_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/update_pharmacy_medicine_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePharmacyMedicineRepository implements PharmacyMedicineRepository {
  String? lastToken;
  int? lastPharmacyMedicineId;
  int? lastMedicineId;
  String? lastTradeName;
  String? lastTradeNameAr;
  String? lastActiveIngredient;
  double? lastPrice;
  int? lastQuantity;
  bool? lastIsAvailable;
  ApiResult<void> updateResult = const Success(null);

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
    lastToken = token;
    lastPharmacyMedicineId = pharmacyMedicineId;
    lastMedicineId = medicineId;
    lastTradeName = tradeName;
    lastTradeNameAr = tradeNameAr;
    lastActiveIngredient = activeIngredient;
    lastPrice = price;
    lastQuantity = quantity;
    lastIsAvailable = isAvailable;
    return updateResult;
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
  late UpdatePharmacyMedicineUseCase useCase;

  setUp(() {
    repository = _FakePharmacyMedicineRepository();
    sessionRepository = _FakeSessionRepository();
    useCase = UpdatePharmacyMedicineUseCase(repository, sessionRepository);
  });

  test('fails without hitting the repository when there is no saved session', () async {
    final result = await useCase(
      pharmacyMedicineId: 1,
      medicineId: 3,
      tradeName: 'Panadol',
      price: 10,
      quantity: 5,
      isAvailable: true,
    );

    expect(result, isA<ApiError<void>>());
    expect(repository.lastToken, isNull);
  });

  test('updates the medicine using the saved session token', () async {
    sessionRepository.savedSession =
        const UserSession(accountType: AccountType.pharmacy, token: 'tok-1');

    final result = await useCase(
      pharmacyMedicineId: 7,
      medicineId: 16,
      tradeName: 'Adol 4',
      tradeNameAr: 'ادول 4',
      activeIngredient: '44',
      price: 12.5,
      quantity: 40,
      isAvailable: false,
    );

    expect(result, isA<Success<void>>());
    expect(repository.lastToken, 'tok-1');
    expect(repository.lastPharmacyMedicineId, 7);
    expect(repository.lastMedicineId, 16);
    expect(repository.lastTradeName, 'Adol 4');
    expect(repository.lastTradeNameAr, 'ادول 4');
    expect(repository.lastActiveIngredient, '44');
    expect(repository.lastPrice, 12.5);
    expect(repository.lastQuantity, 40);
    expect(repository.lastIsAvailable, false);
  });

  test('surfaces a repository failure', () async {
    sessionRepository.savedSession =
        const UserSession(accountType: AccountType.pharmacy, token: 'tok-1');
    repository.updateResult = const ApiError(ApiFailure(message: 'فشل التعديل'));

    final result = await useCase(
      pharmacyMedicineId: 7,
      medicineId: 16,
      tradeName: 'Panadol',
      price: 12.5,
      quantity: 40,
      isAvailable: true,
    );

    expect(result, isA<ApiError<void>>());
  });
}
