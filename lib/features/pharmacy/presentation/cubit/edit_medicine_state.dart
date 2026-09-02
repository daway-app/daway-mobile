import '../../../../core/helpers/arabic_text.dart';

/// Form data for editing an existing pharmacy medicine. Price, quantity,
/// availability, trade name, Arabic trade name, and active ingredient are
/// all editable (confirmed against a live `PUT /pharmacy/medicines/{id}`
/// response — the catalog fields are included in the same request).
class EditMedicineFormData {
  final String tradeName;
  final String nameAr;
  final String activeIngredient;
  final String price;
  final String quantity;
  final bool isAvailable;

  const EditMedicineFormData({
    required this.tradeName,
    this.nameAr = '',
    required this.activeIngredient,
    required this.price,
    required this.quantity,
    required this.isAvailable,
  });

  double? get priceValue => double.tryParse(price);

  int? get quantityValue => int.tryParse(quantity);

  /// The backend rejects `trade_name` if it contains Arabic characters.
  bool get tradeNameHasArabicChars => containsArabicChars(tradeName);

  bool get canSubmit =>
      tradeName.trim().isNotEmpty &&
      !tradeNameHasArabicChars &&
      (priceValue ?? 0) > 0 &&
      (quantityValue ?? 0) > 0;

  EditMedicineFormData copyWith({
    String? tradeName,
    String? nameAr,
    String? activeIngredient,
    String? price,
    String? quantity,
    bool? isAvailable,
  }) {
    return EditMedicineFormData(
      tradeName: tradeName ?? this.tradeName,
      nameAr: nameAr ?? this.nameAr,
      activeIngredient: activeIngredient ?? this.activeIngredient,
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
