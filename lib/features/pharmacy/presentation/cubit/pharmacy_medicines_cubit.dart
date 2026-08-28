import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/usecases/delete_pharmacy_medicine_usecase.dart';
import '../../domain/usecases/get_pharmacy_medicines_usecase.dart';
import 'pharmacy_medicines_state.dart';

class PharmacyMedicinesCubit extends Cubit<PharmacyMedicinesState> {
  final GetPharmacyMedicinesUseCase _getPharmacyMedicinesUseCase;
  final DeletePharmacyMedicineUseCase _deletePharmacyMedicineUseCase;

  PharmacyMedicinesCubit(
    this._getPharmacyMedicinesUseCase,
    this._deletePharmacyMedicineUseCase,
  ) : super(const PharmacyMedicinesLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const PharmacyMedicinesLoading());
    final result = await _getPharmacyMedicinesUseCase();
    switch (result) {
      case Success(:final data):
        emit(PharmacyMedicinesLoaded(medicines: data));
      case ApiError(:final failure):
        emit(PharmacyMedicinesLoadFailure(failure.message));
    }
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
