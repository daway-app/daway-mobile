import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/inventory_item_update.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/usecases/get_pharmacy_inventory_usecase.dart';
import '../../domain/usecases/update_pharmacy_inventory_usecase.dart';
import 'pharmacy_inventory_state.dart';

class PharmacyInventoryCubit extends Cubit<PharmacyInventoryState> {
  final GetPharmacyInventoryUseCase _getPharmacyInventoryUseCase;
  final UpdatePharmacyInventoryUseCase _updatePharmacyInventoryUseCase;

  PharmacyInventoryCubit(
    this._getPharmacyInventoryUseCase,
    this._updatePharmacyInventoryUseCase,
  ) : super(const PharmacyInventoryLoading()) {
    load();
  }

  /// Reloads the list. Also used by [save] after a successful bulk update —
  /// carries the previous query/filter forward across that reload (a
  /// stock-taking session commonly stays within one filter/search across
  /// several saves), but never carries pendingQuantities forward: those
  /// either just got persisted, or belonged to a save that failed and is
  /// handled separately in [save].
  Future<void> load() async {
    final previous = state;
    emit(const PharmacyInventoryLoading());
    final result = await _getPharmacyInventoryUseCase();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(previous is PharmacyInventoryLoaded
            ? PharmacyInventoryLoaded(medicines: data, query: previous.query, filter: previous.filter)
            : PharmacyInventoryLoaded(medicines: data));
      case ApiError(:final failure):
        emit(PharmacyInventoryLoadFailure(failure.message));
    }
  }

  void queryChanged(String value) {
    final current = state;
    if (current is! PharmacyInventoryLoaded) return;
    emit(current.copyWith(query: value, clearSaveError: true));
  }

  void filterChanged(MedicineStatusFilter filter) {
    final current = state;
    if (current is! PharmacyInventoryLoaded) return;
    emit(current.copyWith(filter: filter, clearSaveError: true));
  }

  void increment(Medicine medicine) => _adjust(medicine, 1);

  void decrement(Medicine medicine) => _adjust(medicine, -1);

  void _adjust(Medicine medicine, int delta) {
    final current = state;
    // Edits are blocked while a save is in flight rather than merged into
    // it: the in-flight request already snapshotted its item list, and
    // save()'s post-success reload clears pendingQuantities entirely, so an
    // edit made mid-save would otherwise be accepted locally and then
    // silently wiped without ever being sent.
    if (current is! PharmacyInventoryLoaded || current.isSaving) return;

    final newQuantity = current.quantityFor(medicine) + delta;
    if (newQuantity < 0) return;

    final pending = Map<int, int>.from(current.pendingQuantities);
    if (newQuantity == medicine.quantity) {
      pending.remove(medicine.id);
    } else {
      pending[medicine.id] = newQuantity;
    }
    emit(current.copyWith(pendingQuantities: pending, clearSaveError: true));
  }

  Future<void> save() async {
    final current = state;
    if (current is! PharmacyInventoryLoaded || !current.hasPendingChanges || current.isSaving) {
      return;
    }

    emit(current.copyWith(isSaving: true, clearSaveError: true));

    final medicinesById = {for (final medicine in current.medicines) medicine.id: medicine};
    final items = current.pendingQuantities.entries.map((entry) {
      final medicine = medicinesById[entry.key]!;
      return InventoryItemUpdate(
        pharmacyMedicineId: entry.key,
        quantity: entry.value,
        isAvailable: medicine.isAvailable,
      );
    }).toList();

    final result = await _updatePharmacyInventoryUseCase(items);
    if (isClosed) return;
    switch (result) {
      case Success():
        // Reload rather than patch pendingQuantities into medicines locally:
        // the server may recompute is_low_stock/is_out_of_stock, and this is
        // the only way to pick those up instead of showing stale flags.
        await load();
      case ApiError(:final failure):
        // Re-read state instead of reusing the pre-await `current`: edits
        // are blocked while isSaving, but the user could still have changed
        // query/filter while this request was in flight, and those
        // shouldn't be rolled back just because the save failed.
        final latest = state;
        if (latest is PharmacyInventoryLoaded) {
          emit(latest.copyWith(isSaving: false, saveError: failure.message));
        }
    }
  }
}
