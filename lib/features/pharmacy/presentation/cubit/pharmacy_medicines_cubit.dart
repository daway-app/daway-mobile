import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/inventory_item_update.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/usecases/delete_pharmacy_medicine_usecase.dart';
import '../../domain/usecases/get_pharmacy_medicines_usecase.dart';
import '../../domain/usecases/update_pharmacy_inventory_usecase.dart';
import 'pharmacy_medicines_state.dart';

class PharmacyMedicinesCubit extends Cubit<PharmacyMedicinesState> {
  final GetPharmacyMedicinesUseCase _getPharmacyMedicinesUseCase;
  final DeletePharmacyMedicineUseCase _deletePharmacyMedicineUseCase;
  final UpdatePharmacyInventoryUseCase _updatePharmacyInventoryUseCase;

  // The medicines (by `Medicine.id`) whose stepper quantity is being sent —
  // see [_save].
  final Set<int> _saving = {};

  PharmacyMedicinesCubit(
    this._getPharmacyMedicinesUseCase,
    this._deletePharmacyMedicineUseCase,
    this._updatePharmacyInventoryUseCase,
  ) : super(const PharmacyMedicinesLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const PharmacyMedicinesLoading());
    final result = await _getPharmacyMedicinesUseCase();
    // The shell closes the products page's cubit with itself, possibly mid-load.
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(PharmacyMedicinesLoaded(medicines: data));
      case ApiError(:final failure):
        emit(PharmacyMedicinesLoadFailure(failure.message));
    }
  }

  /// Fetches the list again without going back to the loading state: what is
  /// on screen — with its search, filter and unsaved stepper edits — stays until
  /// the new list arrives, and stays if the fetch fails. With nothing on screen
  /// yet, a load already on its way is left to finish, and a failed one is
  /// retried.
  Future<void> refresh() async {
    final current = state;
    if (current is PharmacyMedicinesLoading) return;
    if (current is PharmacyMedicinesLoadFailure) return load();

    final result = await _getPharmacyMedicinesUseCase();
    if (isClosed) return;
    // Read again: the search, the filter or a stepper may have changed while
    // the list was on its way.
    final latest = state;
    if (result is! Success<List<Medicine>> || latest is! PharmacyMedicinesLoaded) return;
    emit(latest.copyWith(medicines: result.data));
  }

  void queryChanged(String value) {
    final current = state;
    if (current is! PharmacyMedicinesLoaded) return;
    emit(current.copyWith(query: value));
  }

  void filterChanged(MedicineStatusFilter filter) {
    final current = state;
    if (current is! PharmacyMedicinesLoaded) return;
    emit(current.copyWith(filter: filter));
  }

  void increment(Medicine medicine) => _adjust(medicine, 1);

  void decrement(Medicine medicine) => _adjust(medicine, -1);

  /// Shows the new quantity at once and saves it in the background, so the
  /// stepper answers every tap however slow the server is.
  void _adjust(Medicine medicine, int delta) {
    final current = state;
    if (current is! PharmacyMedicinesLoaded) return;

    final quantity = current.quantityFor(medicine) + delta;
    if (quantity < 0) return;

    emit(current.copyWith(
      pendingQuantities: {...current.pendingQuantities, medicine.id: quantity},
      clearStockError: true,
    ));
    if (_saving.add(medicine.id)) _save(medicine);
  }

  /// Sends the quantity the pharmacist wants for [medicine], and sends it again
  /// for as long as another tap changed it while the request was on its way:
  /// one request per medicine at a time, so a burst of taps ends with the last
  /// quantity rather than with whichever response comes back last.
  Future<void> _save(Medicine medicine) async {
    try {
      while (!isClosed) {
        final current = state;
        if (current is! PharmacyMedicinesLoaded) return;
        final wanted = current.pendingQuantities[medicine.id];
        if (wanted == null) return;

        final result = await _updatePharmacyInventoryUseCase([
          InventoryItemUpdate(
            pharmacyMedicineId: medicine.id,
            quantity: wanted,
            isAvailable: medicine.isAvailable,
          ),
        ]);
        if (isClosed) return;
        // Read again: the list, the search or the wanted quantity may have
        // changed while the request was on its way.
        final latest = state;
        if (latest is! PharmacyMedicinesLoaded) return;

        final pending = {...latest.pendingQuantities};
        switch (result) {
          case Success():
            if (pending[medicine.id] == wanted) pending.remove(medicine.id);
            emit(latest.copyWith(
              medicines: [
                for (final saved in latest.medicines)
                  saved.id == medicine.id ? saved.copyWithQuantity(wanted) : saved,
              ],
              pendingQuantities: pending,
            ));
          case ApiError(:final failure):
            // Back to the last saved quantity, and say why.
            pending.remove(medicine.id);
            emit(latest.copyWith(pendingQuantities: pending, stockError: failure.message));
            return;
        }
      }
    } finally {
      _saving.remove(medicine.id);
    }
  }

  /// Returns null on success, or a user-facing error message on failure —
  /// lets the screen show a snackbar without the cubit owning UI feedback.
  Future<String?> deleteMedicine(int pharmacyMedicineId) async {
    final current = state;
    if (current is! PharmacyMedicinesLoaded) return null;

    final result = await _deletePharmacyMedicineUseCase(pharmacyMedicineId);
    switch (result) {
      case Success():
        emit(current.copyWith(
          medicines:
              current.medicines.where((medicine) => medicine.id != pharmacyMedicineId).toList(),
        ));
        return null;
      case ApiError(:final failure):
        return failure.message;
    }
  }
}
