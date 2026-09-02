import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine_catalog_item.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_medicine_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/delete_pharmacy_medicine_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_medicines_usecase.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_medicines_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_medicines_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _available = Medicine(
  id: 1,
  medicineId: 5,
  name: 'Panadol',
  activeIngredient: 'Paracetamol 500mg',
  price: 25,
  quantity: 120,
  isAvailable: true,
);
const _low = Medicine(
  id: 2,
  medicineId: 6,
  name: 'Amoxil',
  activeIngredient: 'Amoxicillin 500mg',
  price: 18.5,
  quantity: 3,
  isAvailable: true,
);
const _outOfStock = Medicine(
  id: 3,
  medicineId: 7,
  name: 'Aspirin',
  activeIngredient: 'Acetylsalicylic acid',
  price: 10,
  quantity: 0,
  isAvailable: true,
);

class _FakePharmacyMedicineRepository implements PharmacyMedicineRepository {
  ApiResult<List<Medicine>> getResult = const Success([_available, _low, _outOfStock]);
  ApiResult<void> deleteResult = const Success(null);
  int? lastDeletedId;

  @override
  Future<ApiResult<List<Medicine>>> getMedicines({required String token}) async => getResult;

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
    lastDeletedId = pharmacyMedicineId;
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
  late PharmacyMedicinesCubit cubit;

  setUp(() async {
    repository = _FakePharmacyMedicineRepository();
    final sessionRepository = _FakeSessionRepository();
    cubit = PharmacyMedicinesCubit(
      GetPharmacyMedicinesUseCase(repository, sessionRepository),
      DeletePharmacyMedicineUseCase(repository, sessionRepository),
    );
    await cubit.load();
  });

  tearDown(() => cubit.close());

  test('loads all medicines', () {
    final state = cubit.state as PharmacyMedicinesLoaded;
    expect(state.medicines.length, 3);
    expect(state.filteredMedicines.length, 3);
  });

  test('surfaces a load failure', () async {
    repository.getResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));

    await cubit.load();

    expect(cubit.state, isA<PharmacyMedicinesLoadFailure>());
  });

  test('filterChanged narrows the list by stock status', () {
    cubit.filterChanged(MedicineStatusFilter.low);

    final state = cubit.state as PharmacyMedicinesLoaded;
    expect(state.filteredMedicines, [_low]);
  });

  test('queryChanged filters by name or active ingredient, case-insensitively', () {
    cubit.queryChanged('paracetamol');
    expect((cubit.state as PharmacyMedicinesLoaded).filteredMedicines, [_available]);

    cubit.queryChanged('amoxil');
    expect((cubit.state as PharmacyMedicinesLoaded).filteredMedicines, [_low]);

    cubit.queryChanged('نو نتيجة');
    expect((cubit.state as PharmacyMedicinesLoaded).filteredMedicines, isEmpty);
  });

  test('query and filter combine', () {
    cubit.filterChanged(MedicineStatusFilter.outOfStock);
    cubit.queryChanged('aspirin');

    expect((cubit.state as PharmacyMedicinesLoaded).filteredMedicines, [_outOfStock]);
  });

  test('deleteMedicine removes the medicine from the local list on success', () async {
    final error = await cubit.deleteMedicine(_low.id);

    expect(error, isNull);
    expect(repository.lastDeletedId, _low.id);
    final state = cubit.state as PharmacyMedicinesLoaded;
    expect(state.medicines, [_available, _outOfStock]);
  });

  test('deleteMedicine returns the failure message and keeps the list on error', () async {
    repository.deleteResult = const ApiError(ApiFailure(message: 'فشل الحذف'));

    final error = await cubit.deleteMedicine(_low.id);

    expect(error, 'فشل الحذف');
    final state = cubit.state as PharmacyMedicinesLoaded;
    expect(state.medicines, [_available, _low, _outOfStock]);
  });
}
