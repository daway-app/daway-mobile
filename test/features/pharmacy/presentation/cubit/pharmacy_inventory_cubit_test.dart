import 'dart:async';

import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/inventory_item_update.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_inventory_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_inventory_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/update_pharmacy_inventory_usecase.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_inventory_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_inventory_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _available = Medicine(
  id: 1,
  medicineId: 5,
  name: 'Panadol',
  activeIngredient: 'Paracetamol 500mg',
  price: 12,
  quantity: 120,
  isAvailable: true,
);
const _low = Medicine(
  id: 2,
  medicineId: 6,
  name: 'Amoxil',
  nameAr: 'أموكسيل',
  activeIngredient: 'Amoxicillin 500mg',
  price: 15,
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
  isAvailable: false,
);

class _FakePharmacyInventoryRepository implements PharmacyInventoryRepository {
  ApiResult<List<Medicine>> getResult = const Success([_available, _low, _outOfStock]);
  ApiResult<void> updateResult = const Success(null);
  List<InventoryItemUpdate>? lastItems;
  int updateCallCount = 0;

  /// When set, updateInventory() waits for this to complete instead of
  /// resolving immediately — lets a test pause mid-save to exercise races
  /// between an in-flight save and further cubit calls.
  Completer<void>? updateGate;

  @override
  Future<ApiResult<List<Medicine>>> getInventory({required String token}) async => getResult;

  @override
  Future<ApiResult<void>> updateInventory({
    required String token,
    required List<InventoryItemUpdate> items,
  }) async {
    updateCallCount++;
    lastItems = items;
    if (updateGate != null) await updateGate!.future;
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
  late _FakePharmacyInventoryRepository repository;
  late PharmacyInventoryCubit cubit;

  setUp(() async {
    repository = _FakePharmacyInventoryRepository();
    final sessionRepository = _FakeSessionRepository();
    cubit = PharmacyInventoryCubit(
      GetPharmacyInventoryUseCase(repository, sessionRepository),
      UpdatePharmacyInventoryUseCase(repository, sessionRepository),
    );
    await cubit.load();
  });

  tearDown(() => cubit.close());

  test('loads all medicines with stats tallied from their quantities', () {
    final state = cubit.state as PharmacyInventoryLoaded;
    expect(state.medicines.length, 3);
    expect(state.statusTally, (available: 1, low: 1, outOfStock: 1));
    expect(state.hasPendingChanges, isFalse);
  });

  test('surfaces a load failure', () async {
    repository.getResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));

    await cubit.load();

    expect(cubit.state, isA<PharmacyInventoryLoadFailure>());
  });

  test('increment/decrement adjust the displayed quantity without hitting the network', () {
    cubit.increment(_available);
    var state = cubit.state as PharmacyInventoryLoaded;
    expect(state.quantityFor(_available), 121);
    expect(state.hasPendingChanges, isTrue);

    cubit.decrement(_available);
    state = cubit.state as PharmacyInventoryLoaded;
    expect(state.quantityFor(_available), 120);
    // Back to the original value — no longer a pending change.
    expect(state.hasPendingChanges, isFalse);
  });

  test('decrement never takes a quantity below zero', () {
    cubit.decrement(_outOfStock);

    final state = cubit.state as PharmacyInventoryLoaded;
    expect(state.quantityFor(_outOfStock), 0);
  });

  test('a pending edit recomputes stock status and stats live, before saving', () {
    // _low starts at quantity 3 (low); pushing it to 20 should read as
    // available in both its own status and the header tally, even though
    // nothing has been saved yet.
    for (var i = 0; i < 17; i++) {
      cubit.increment(_low);
    }

    final state = cubit.state as PharmacyInventoryLoaded;
    expect(state.quantityFor(_low), 20);
    expect(state.statusFor(_low), MedicineStatus.available);
    expect(state.statusTally, (available: 2, low: 0, outOfStock: 1));
  });

  test('queryChanged filters by name, Arabic name, or active ingredient', () {
    cubit.queryChanged('amoxicillin');
    expect((cubit.state as PharmacyInventoryLoaded).filteredMedicines, [_low]);

    cubit.queryChanged('أموكسيل');
    expect((cubit.state as PharmacyInventoryLoaded).filteredMedicines, [_low]);
  });

  test('filterChanged narrows the list by stock status', () {
    cubit.filterChanged(MedicineStatusFilter.low);

    final state = cubit.state as PharmacyInventoryLoaded;
    expect(state.filteredMedicines, [_low]);
  });

  test('filter tracks pending edits, not just the saved quantity', () {
    // _outOfStock starts at quantity 0 (not "available"); bump it above the
    // low-stock threshold and it should immediately join the "available"
    // filter results, before anything is saved.
    for (var i = 0; i < 15; i++) {
      cubit.increment(_outOfStock);
    }
    cubit.filterChanged(MedicineStatusFilter.available);

    final state = cubit.state as PharmacyInventoryLoaded;
    expect(state.filteredMedicines, [_available, _outOfStock]);
  });

  test('filter and query combine', () {
    cubit.filterChanged(MedicineStatusFilter.available);
    cubit.queryChanged('aspirin');

    expect((cubit.state as PharmacyInventoryLoaded).filteredMedicines, isEmpty);
  });

  test('save sends only the changed items, preserving each one\'s isAvailable', () async {
    cubit.increment(_available); // 120 -> 121
    cubit.decrement(_outOfStock); // stays 0, no-op, not pending
    for (var i = 0; i < 5; i++) {
      cubit.decrement(_low); // 3 -> 0
    }

    await cubit.save();

    final items = repository.lastItems!;
    expect(items, hasLength(2));
    expect(
      items,
      containsAll([
        const InventoryItemUpdate(pharmacyMedicineId: 1, quantity: 121, isAvailable: true),
        const InventoryItemUpdate(pharmacyMedicineId: 2, quantity: 0, isAvailable: true),
      ]),
    );
  });

  test('save reloads from the server and clears pending edits on success', () async {
    cubit.increment(_available);

    await cubit.save();

    final state = cubit.state as PharmacyInventoryLoaded;
    expect(state.hasPendingChanges, isFalse);
    expect(state.quantityFor(_available), 120);
  });

  test('save keeps the pending edit and surfaces the error on failure', () async {
    cubit.increment(_available);
    repository.updateResult = const ApiError(ApiFailure(message: 'فشل الحفظ'));

    await cubit.save();

    final state = cubit.state as PharmacyInventoryLoaded;
    expect(state.saveError, 'فشل الحفظ');
    expect(state.quantityFor(_available), 121);
    expect(state.isSaving, isFalse);
  });

  test('save does nothing when there are no pending changes', () async {
    await cubit.save();

    expect(repository.lastItems, isNull);
  });

  test('statusFor defers to the server flags for an item with no pending edit', () {
    // _available has no is_low_stock/is_out_of_stock flags set in these
    // fixtures (both null), so this exercises the medicineStatusFor
    // fallback; a medicine with server flags set is covered by
    // medicine_test.dart's own Medicine.status coverage — this test is
    // about *which* source statusFor consults, not the flags themselves.
    final state = cubit.state as PharmacyInventoryLoaded;

    expect(state.statusFor(_available), _available.status);
  });

  test('queryChanged and filterChanged clear a previous save error', () async {
    cubit.increment(_available);
    repository.updateResult = const ApiError(ApiFailure(message: 'فشل الحفظ'));
    await cubit.save();
    expect((cubit.state as PharmacyInventoryLoaded).saveError, isNotNull);

    cubit.queryChanged('panadol');
    expect((cubit.state as PharmacyInventoryLoaded).saveError, isNull);

    cubit.increment(_available); // still a pending change (122), re-arm the error
    repository.updateResult = const ApiError(ApiFailure(message: 'فشل الحفظ'));
    await cubit.save();
    expect((cubit.state as PharmacyInventoryLoaded).saveError, isNotNull);

    cubit.filterChanged(MedicineStatusFilter.available);
    expect((cubit.state as PharmacyInventoryLoaded).saveError, isNull);
  });

  test('a second save() call while one is in flight is a no-op', () async {
    cubit.increment(_available);
    repository.updateGate = Completer<void>();

    final firstSave = cubit.save();
    await cubit.save(); // isSaving is already true — should not re-enter

    repository.updateGate!.complete();
    await firstSave;

    expect(repository.updateCallCount, 1);
  });

  test('increment/decrement are ignored while a save is in flight', () async {
    cubit.increment(_available); // 120 -> 121, pending
    repository.updateGate = Completer<void>();
    final pendingSave = cubit.save();

    cubit.increment(_low); // must not be accepted: save() already snapshotted its items
    expect((cubit.state as PharmacyInventoryLoaded).hasPendingChanges, isTrue);
    expect((cubit.state as PharmacyInventoryLoaded).quantityFor(_low), _low.quantity);

    repository.updateGate!.complete();
    await pendingSave;

    // Only the item included in the sent request exists; _low was never queued.
    expect(repository.lastItems, [
      const InventoryItemUpdate(pharmacyMedicineId: 1, quantity: 121, isAvailable: true),
    ]);
  });

  test('load (including the reload after a successful save) preserves query and filter', () async {
    cubit.queryChanged('amox');
    cubit.filterChanged(MedicineStatusFilter.low);
    cubit.increment(_low);

    await cubit.save();

    final state = cubit.state as PharmacyInventoryLoaded;
    expect(state.query, 'amox');
    expect(state.filter, MedicineStatusFilter.low);
  });

  test('a failed save does not roll back query/filter changes made while it was in flight', () async {
    cubit.increment(_available);
    repository.updateGate = Completer<void>();
    repository.updateResult = const ApiError(ApiFailure(message: 'فشل الحفظ'));
    final pendingSave = cubit.save();

    // _adjust is blocked while isSaving, but query/filter aren't edits —
    // they're still expected to apply immediately.
    cubit.queryChanged('aspirin');
    cubit.filterChanged(MedicineStatusFilter.outOfStock);

    repository.updateGate!.complete();
    await pendingSave;

    final state = cubit.state as PharmacyInventoryLoaded;
    expect(state.saveError, 'فشل الحفظ');
    expect(state.query, 'aspirin');
    expect(state.filter, MedicineStatusFilter.outOfStock);
  });
}
