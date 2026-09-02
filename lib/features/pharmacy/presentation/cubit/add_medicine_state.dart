import '../../../../core/helpers/arabic_text.dart';
import '../../domain/entities/medicine_catalog_item.dart';

/// Form data carried across every state so the screen never loses what the
/// user has already entered while a search, image upload, or submission is
/// in flight.
class AddMedicineFormData {
  final String nameQuery;
  final List<MedicineCatalogItem> suggestions;
  final bool isSearching;
  final String? searchError;
  final MedicineCatalogItem? selectedMedicine;

  /// True once the pharmacist taps "الدواء غير موجود؟ أضفه يدوياً" — search
  /// stops, and [nameQuery]/[nameAr]/[activeIngredient] are sent to
  /// `POST /pharmacy/medicines/by-name` instead of requiring a selection.
  final bool isManualEntry;

  /// The Arabic trade name, used only in manual entry (optional there).
  final String nameAr;

  /// Auto-filled from [selectedMedicine] when a catalog match is picked, but
  /// freely editable afterwards — also the value sent as `active_ingredient`
  /// in manual entry.
  final String activeIngredient;
  final String quantity;
  final String price;
  final bool isAvailable;
  final String? imageLocalPath;
  final String? imageUrl;
  final bool isUploadingImage;
  final String? imageError;

  const AddMedicineFormData({
    this.nameQuery = '',
    this.suggestions = const [],
    this.isSearching = false,
    this.searchError,
    this.selectedMedicine,
    this.isManualEntry = false,
    this.nameAr = '',
    this.activeIngredient = '',
    this.quantity = '',
    this.price = '',
    this.isAvailable = true,
    this.imageLocalPath,
    this.imageUrl,
    this.isUploadingImage = false,
    this.imageError,
  });

  double? get priceValue => double.tryParse(price);

  int? get quantityValue => int.tryParse(quantity);

  /// The backend rejects `trade_name` if it contains Arabic characters.
  bool get nameHasArabicChars => containsArabicChars(nameQuery);

  bool get canSubmit =>
      (isManualEntry
          ? nameQuery.trim().isNotEmpty && !nameHasArabicChars
          : selectedMedicine != null) &&
      (quantityValue ?? 0) > 0 &&
      (priceValue ?? 0) > 0 &&
      !isUploadingImage;

  AddMedicineFormData copyWith({
    String? nameQuery,
    List<MedicineCatalogItem>? suggestions,
    bool? isSearching,
    String? searchError,
    bool clearSearchError = false,
    MedicineCatalogItem? selectedMedicine,
    bool clearSelectedMedicine = false,
    bool? isManualEntry,
    String? nameAr,
    String? activeIngredient,
    String? quantity,
    String? price,
    bool? isAvailable,
    String? imageLocalPath,
    String? imageUrl,
    bool clearImageUrl = false,
    bool? isUploadingImage,
    String? imageError,
    bool clearImageError = false,
  }) {
    return AddMedicineFormData(
      nameQuery: nameQuery ?? this.nameQuery,
      suggestions: suggestions ?? this.suggestions,
      isSearching: isSearching ?? this.isSearching,
      searchError: clearSearchError ? null : (searchError ?? this.searchError),
      selectedMedicine:
          clearSelectedMedicine ? null : (selectedMedicine ?? this.selectedMedicine),
      isManualEntry: isManualEntry ?? this.isManualEntry,
      nameAr: nameAr ?? this.nameAr,
      activeIngredient: activeIngredient ?? this.activeIngredient,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      imageLocalPath: imageLocalPath ?? this.imageLocalPath,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      imageError: clearImageError ? null : (imageError ?? this.imageError),
    );
  }
}

sealed class AddMedicineState {
  final AddMedicineFormData formData;

  const AddMedicineState(this.formData);
}

class AddMedicineEditing extends AddMedicineState {
  const AddMedicineEditing(super.formData);
}

class AddMedicineSaving extends AddMedicineState {
  const AddMedicineSaving(super.formData);
}

class AddMedicineSuccess extends AddMedicineState {
  const AddMedicineSuccess(super.formData);
}

class AddMedicineFailure extends AddMedicineState {
  final String message;

  const AddMedicineFailure(super.formData, this.message);
}
