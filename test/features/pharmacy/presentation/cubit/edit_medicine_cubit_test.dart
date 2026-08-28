import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine_catalog_item.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_medicine_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/update_pharmacy_medicine_usecase.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/edit_medicine_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/edit_medicine_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _medicine = Medicine(
  id: 7,
  medicineId: 3,
  name: 'Panadol',
  activeIngredient: 'Paracetamol 500mg',
  price: 12.5,
  quantity: 40,
  isAvailable: true,
);

class _FakePharmacyMedicineRepository implements PharmacyMedicineRepository {
  int? lastPharmacyMedicineId;
  int? lastMedicineId;
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
    required double price,
    required int quantity,
    required bool isAvailable,
  }) async {
    lastPharmacyMedicineId = pharmacyMedicineId;
    lastMedicineId = medicineId;
    lastPrice = price;
    lastQuantity = quantity;
    lastIsAvailable = isAvailable;
    return updateResult;
  }
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession =
      const UserSession(accountType: AccountType.pharmacy, token: 'tok-1');

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
  late EditMedicineCubit cubit;

  setUp(() {
    repository = _FakePharmacyMedicineRepository();
    final sessionRepository = _FakeSessionRepository();
    cubit = EditMedicineCubit(
      UpdatePharmacyMedicineUseCase(repository, sessionRepository),
      _medicine,
    );
  });

  tearDown(() => cubit.close());

  test('starts pre-filled from the given medicine', () {
    final formData = cubit.state.formData;
    expect(formData.price, '12.50');
    expect(formData.quantity, '40');
    expect(formData.isAvailable, isTrue);
    expect(formData.canSubmit, isTrue);
  });

  test('a zero quantity is not submittable', () {
    cubit.quantityChanged('0');

    expect(cubit.state.formData.canSubmit, isFalse);
  });

  test('save sends the edited fields for the original medicine id', () async {
    cubit.priceChanged('18');
    cubit.quantityChanged('25');
    cubit.isAvailableChanged(false);

    await cubit.save();

    expect(cubit.state, isA<EditMedicineSuccess>());
    expect(repository.lastPharmacyMedicineId, 7);
    expect(repository.lastMedicineId, 3);
    expect(repository.lastPrice, 18);
    expect(repository.lastQuantity, 25);
    expect(repository.lastIsAvailable, false);
  });

  test('save does not call the repository when the form is not submittable', () async {
    cubit.quantityChanged('0');

    await cubit.save();

    expect(repository.lastPharmacyMedicineId, isNull);
    expect(cubit.state, isA<EditMedicineEditing>());
  });

  test('surfaces a repository failure without losing the entered values', () async {
    repository.updateResult = const ApiError(ApiFailure(message: 'فشل التعديل'));
    cubit.priceChanged('18');

    await cubit.save();

    final state = cubit.state;
    expect(state, isA<EditMedicineFailure>());
    expect((state as EditMedicineFailure).message, 'فشل التعديل');
    expect(state.formData.price, '18');
  });
}
