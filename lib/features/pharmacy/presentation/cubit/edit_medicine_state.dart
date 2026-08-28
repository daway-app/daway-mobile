/// Form data for editing an existing pharmacy medicine's stock fields —
/// only price, quantity, and availability are editable; the trade name and
/// active ingredient belong to the shared catalog entry, not this
/// pharmacy's listing, so they're shown read-only by the screen instead.
class EditMedicineFormData {
  final String price;
  final String quantity;
  final bool isAvailable;

  const EditMedicineFormData({
    required this.price,
    required this.quantity,
    required this.isAvailable,
  });

  double? get priceValue => double.tryParse(price);

  int? get quantityValue => int.tryParse(quantity);

  bool get canSubmit => (priceValue ?? 0) > 0 && (quantityValue ?? 0) > 0;

  EditMedicineFormData copyWith({
    String? price,
    String? quantity,
    bool? isAvailable,
  }) {
    return EditMedicineFormData(
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

sealed class EditMedicineState {
  final EditMedicineFormData formData;

  const EditMedicineState(this.formData);
}

class EditMedicineEditing extends EditMedicineState {
  const EditMedicineEditing(super.formData);
}

class EditMedicineSaving extends EditMedicineState {
  const EditMedicineSaving(super.formData);
}

class EditMedicineSuccess extends EditMedicineState {
  const EditMedicineSuccess(super.formData);
}

class EditMedicineFailure extends EditMedicineState {
  final String message;

  const EditMedicineFailure(super.formData, this.message);
}
