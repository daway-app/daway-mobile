import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/usecases/update_pharmacy_medicine_usecase.dart';
import 'edit_medicine_state.dart';

class EditMedicineCubit extends Cubit<EditMedicineState> {
  final UpdatePharmacyMedicineUseCase _updatePharmacyMedicineUseCase;
  final int _pharmacyMedicineId;
  final int _medicineId;

  EditMedicineCubit(this._updatePharmacyMedicineUseCase, Medicine medicine)
      : _pharmacyMedicineId = medicine.id,
        _medicineId = medicine.medicineId,
        super(EditMedicineEditing(EditMedicineFormData(
          tradeName: medicine.name,
          nameAr: medicine.nameAr ?? '',
          activeIngredient: medicine.activeIngredient ?? '',
          price: medicine.price.toStringAsFixed(2),
          quantity: medicine.quantity.toString(),
          isAvailable: medicine.isAvailable,
        )));

  void tradeNameChanged(String value) {
    emit(EditMedicineEditing(state.formData.copyWith(tradeName: value)));
  }

  void nameArChanged(String value) {
    emit(EditMedicineEditing(state.formData.copyWith(nameAr: value)));
  }

  void activeIngredientChanged(String value) {
    emit(EditMedicineEditing(state.formData.copyWith(activeIngredient: value)));
  }

  void priceChanged(String value) {
    emit(EditMedicineEditing(state.formData.copyWith(price: value)));
  }

  void quantityChanged(String value) {
    emit(EditMedicineEditing(state.formData.copyWith(quantity: value)));
  }

  void isAvailableChanged(bool value) {
    emit(EditMedicineEditing(state.formData.copyWith(isAvailable: value)));
  }

  Future<void> save() async {
    final formData = state.formData;
    if (!formData.canSubmit) return;

    emit(EditMedicineSaving(formData));

    final result = await _updatePharmacyMedicineUseCase(
      pharmacyMedicineId: _pharmacyMedicineId,
      medicineId: _medicineId,
      tradeName: formData.tradeName.trim(),
      tradeNameAr: formData.nameAr.trim().isEmpty ? null : formData.nameAr.trim(),
      activeIngredient:
          formData.activeIngredient.trim().isEmpty ? null : formData.activeIngredient.trim(),
      price: formData.priceValue!,
      quantity: formData.quantityValue!,
      isAvailable: formData.isAvailable,
    );

    switch (result) {
      case Success():
        emit(EditMedicineSuccess(formData));
      case ApiError(:final failure):
        emit(EditMedicineFailure(formData, failure.message));
    }
  }
}
