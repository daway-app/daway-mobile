import 'dart:async';

import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/inventory_item_update.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine_catalog_item.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_inventory_repository.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_medicine_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/delete_pharmacy_medicine_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_medicines_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/update_pharmacy_inventory_usecase.dart';
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
  int getCalls = 0;

  /// When set, the list only arrives once this completes.
  Future<void>? getGate;

  @override
  Future<ApiResult<List<Medicine>>> getMedicines({required String token}) async {
    getCalls++;
    await getGate;
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

/// Answers each stock save at once, or — with [holdResponses] — only when the
/// test completes it, to play out taps that arrive while a save is on its way.
class _FakePharmacyInventoryRepository implements PharmacyInventoryRepository {
  ApiResult<void> updateResult = const Success(null);
  bool holdResponses = false;
  final List<List<InventoryItemUpdate>> requests = [];
  final List<Completer<ApiResult<void>>> held = [];

  @override
  Future<ApiResult<List<Medicine>>> getInventory({required String token}) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<void>> updateInventory({
    required String token,
    required List<InventoryItemUpdate> items,
  }) {
    requests.add(items);
    if (!holdResponses) return Future.value(updateResult);
    final completer = Completer<ApiResult<void>>();
    held.add(completer);
    return completer.future;
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
  late _FakePharmacyInventoryRepository inventoryRepository;
  late _FakeSessionRepository sessionRepository;
  late PharmacyMedicinesCubit cubit;

  PharmacyMedicinesCubit buildCubit() => PharmacyMedicinesCubit(
        GetPharmacyMedicinesUseCase(repository, sessionRepository),
        DeletePharmacyMedicineUseCase(repository, sessionRepository),
        UpdatePharmacyInventoryUseCase(inventoryRepository, sessionRepository),
      );

  PharmacyMedicinesLoaded loaded() => cubit.state as PharmacyMedicinesLoaded;

  // Lets a save a tap started run on to its next await.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  setUp(() async {
    repository = _FakePharmacyMedicineRepository();
    inventoryRepository = _FakePharmacyInventoryRepository();
    sessionRepository = _FakeSessionRepository();
    cubit = buildCubit();
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

  test('closing the cubit while the list is loading is not an error', () async {
    final gate = Completer<void>();
    repository.getGate = gate.future;
    final loading = buildCubit();
    await settle();

    await loading.close();
    gate.complete();
    // A state emitted after the close would throw here, out of the load.
    await settle();

    expect(loading.isClosed, isTrue);
  });

  group('stepper', () {
    test('increment shows the new quantity at once and saves it', () async {
      inventoryRepository.holdResponses = true;

      cubit.increment(_available);
      await settle();

      expect(loaded().quantityFor(_available), 121);
      expect(loaded().pendingQuantities, {1: 121});
      expect(inventoryRepository.requests, [
        [const InventoryItemUpdate(pharmacyMedicineId: 1, quantity: 121, isAvailable: true)],
      ]);

      inventoryRepository.held.single.complete(const Success(null));
      await settle();

      expect(loaded().pendingQuantities, isEmpty);
      expect(loaded().medicines.first.quantity, 121);
    });

    test('decrement lowers the quantity, and never below zero', () async {
      cubit.decrement(_low);
      await settle();
      expect(loaded().medicines[1].quantity, 2);

      cubit.decrement(_outOfStock);
      await settle();

      expect(loaded().medicines[2].quantity, 0);
      expect(loaded().pendingQuantities, isEmpty);
      expect(inventoryRepository.requests.length, 1);
    });

    test('taps while a save is on its way are followed by one save of the last quantity',
        () async {
      inventoryRepository.holdResponses = true;

      cubit.increment(_available);
      cubit.increment(_available);
      cubit.increment(_available);
      await settle();

      expect(loaded().quantityFor(_available), 123);
      expect(inventoryRepository.requests.length, 1);

      inventoryRepository.held[0].complete(const Success(null));
      await settle();

      expect(inventoryRepository.requests.length, 2);
      expect(inventoryRepository.requests.last.single.quantity, 123);
      // The first answer must not put the quantity back to 121.
      expect(loaded().quantityFor(_available), 123);

      inventoryRepository.held[1].complete(const Success(null));
      await settle();

      expect(loaded().pendingQuantities, isEmpty);
      expect(loaded().medicines.first.quantity, 123);
    });

    test('two medicines are saved independently', () async {
      inventoryRepository.holdResponses = true;

      cubit.increment(_available);
      cubit.decrement(_low);
      await settle();

      expect(inventoryRepository.requests.length, 2);
      expect(loaded().pendingQuantities, {1: 121, 2: 2});
    });

    test('a failed save puts the quantity back and says why', () async {
      inventoryRepository.updateResult = const ApiError(ApiFailure(message: 'فشل التحديث'));

      cubit.increment(_available);
      await settle();

      expect(loaded().pendingQuantities, isEmpty);
      expect(loaded().medicines.first.quantity, 120);
      expect(loaded().stockError, 'فشل التحديث');
    });

    test('the next tap after a failure clears the error and saves again', () async {
      inventoryRepository.updateResult = const ApiError(ApiFailure(message: 'فشل التحديث'));
      cubit.increment(_available);
      await settle();
      inventoryRepository.updateResult = const Success(null);

      cubit.increment(_available);
      expect(loaded().stockError, isNull);
      await settle();

      expect(loaded().medicines.first.quantity, 121);
      expect(inventoryRepository.requests.length, 2);
    });

    test('a saved quantity gives the medicine the status of that quantity', () async {
      // The flags say low, which describes 3 and not the 11 it is raised to.
      repository.getResult = const Success([
        Medicine(
          id: 2,
          medicineId: 6,
          name: 'Amoxil',
          price: 18.5,
          quantity: 3,
          isAvailable: true,
          isLowStock: true,
          isOutOfStock: false,
        ),
      ]);
      await cubit.load();

      for (var i = 0; i < 8; i++) {
        cubit.increment(loaded().medicines.single);
        await settle();
      }

      expect(loaded().medicines.single.quantity, 11);
      expect(loaded().medicines.single.status, MedicineStatus.available);
    });

    test('the status and the filter follow a quantity that is still being saved', () {
      inventoryRepository.holdResponses = true;
      cubit.filterChanged(MedicineStatusFilter.low);
      expect(loaded().filteredMedicines, [_low]);

      for (var i = 0; i < 8; i++) {
        cubit.increment(_low);
      }

      expect(loaded().quantityFor(_low), 11);
      expect(loaded().statusFor(_low), MedicineStatus.available);
      expect(loaded().filteredMedicines, isEmpty);
    });

    test('does nothing while there is no list', () async {
      repository.getResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
      await cubit.load();

      cubit.increment(_available);

      expect(cubit.state, isA<PharmacyMedicinesLoadFailure>());
      expect(inventoryRepository.requests, isEmpty);
    });
  });

  group('refresh', () {
    test('swaps in the new list without a loading state', () async {
      final states = <PharmacyMedicinesState>[];
      final subscription = cubit.stream.listen(states.add);
      repository.getResult = const Success([_available]);

      await cubit.refresh();
      await settle();

      expect(states.length, 1);
      expect(loaded().medicines, [_available]);
      await subscription.cancel();
    });

    test('keeps the search and the filter', () async {
      cubit.queryChanged('amox');
      cubit.filterChanged(MedicineStatusFilter.low);

      await cubit.refresh();

      expect(loaded().query, 'amox');
      expect(loaded().filter, MedicineStatusFilter.low);
    });

    test('keeps a stepper edit that is still being saved', () async {
      inventoryRepository.holdResponses = true;
      cubit.increment(_available);

      await cubit.refresh();

      expect(loaded().quantityFor(_available), 121);
    });

    test('keeps what is on screen when the fetch fails', () async {
      repository.getResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));

      await cubit.refresh();

      expect(loaded().medicines.length, 3);
    });

    test('retries a load that failed', () async {
      repository.getResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
      await cubit.load();
      repository.getResult = const Success([_available]);

      await cubit.refresh();

      expect(loaded().medicines, [_available]);
    });

    test('does not fetch a second time while the first load is on its way', () async {
      final gate = Completer<void>();
      repository.getGate = gate.future;
      final before = repository.getCalls;
      final loading = buildCubit();
      await settle();

      await loading.refresh();

      expect(loading.state, isA<PharmacyMedicinesLoading>());
      // Its own load, and the refresh added none.
      expect(repository.getCalls, before + 1);
      gate.complete();
      await settle();
      await loading.close();
    });
  });
}
