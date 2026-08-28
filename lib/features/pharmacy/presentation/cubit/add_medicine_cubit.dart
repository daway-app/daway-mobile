import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../../patient/domain/usecases/upload_avatar_usecase.dart';
import '../../domain/entities/medicine_catalog_item.dart';
import '../../domain/usecases/add_pharmacy_medicine_by_name_usecase.dart';
import '../../domain/usecases/add_pharmacy_medicine_usecase.dart';
import '../../domain/usecases/search_medicine_catalog_usecase.dart';
import 'add_medicine_state.dart';

class AddMedicineCubit extends Cubit<AddMedicineState> {
  final SearchMedicineCatalogUseCase _searchMedicineCatalogUseCase;
  final AddPharmacyMedicineUseCase _addPharmacyMedicineUseCase;
  final AddPharmacyMedicineByNameUseCase _addPharmacyMedicineByNameUseCase;
  final UploadAvatarUseCase _uploadImageUseCase;

  AddMedicineCubit(
    this._searchMedicineCatalogUseCase,
    this._addPharmacyMedicineUseCase,
    this._addPharmacyMedicineByNameUseCase,
    this._uploadImageUseCase,
  ) : super(const AddMedicineEditing(AddMedicineFormData()));

  Timer? _searchDebounce;

  // Bumped whenever the query is cleared or a suggestion is picked, so a
  // search that was already in flight can tell its result is stale and
  // discard it instead of resurrecting suggestions the user no longer wants.
  int _searchSession = 0;

  // Bumped on every image pick, so an earlier upload that's still in flight
  // can tell its result is stale and won't overwrite a newer pick.
  int _imageSession = 0;

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }

  void nameQueryChanged(String value) {
    if (state.formData.isManualEntry) {
      emit(AddMedicineEditing(state.formData.copyWith(nameQuery: value)));
      return;
    }

    final session = ++_searchSession;
    _searchDebounce?.cancel();
    emit(AddMedicineEditing(state.formData.copyWith(
      nameQuery: value,
      clearSelectedMedicine: true,
      activeIngredient: '',
      suggestions: const [],
      isSearching: false,
      clearSearchError: true,
    )));

    if (value.trim().length < 2) return;

    _searchDebounce = Timer(const Duration(milliseconds: 350), () => _search(value, session));
  }

  Future<void> _search(String query, int session) async {
    emit(AddMedicineEditing(state.formData.copyWith(isSearching: true, clearSearchError: true)));

    final result = await _searchMedicineCatalogUseCase(query);
    if (session != _searchSession) return;

    switch (result) {
      case Success(:final data):
        emit(AddMedicineEditing(state.formData.copyWith(isSearching: false, suggestions: data)));
      case ApiError(:final failure):
        emit(AddMedicineEditing(state.formData.copyWith(
          isSearching: false,
          suggestions: const [],
          searchError: failure.message,
        )));
    }
  }

  void medicineSelected(MedicineCatalogItem medicine) {
    _searchSession++;
    _searchDebounce?.cancel();
    emit(AddMedicineEditing(state.formData.copyWith(
      nameQuery: medicine.name,
      selectedMedicine: medicine,
      activeIngredient: medicine.activeIngredient ?? '',
      suggestions: const [],
      isSearching: false,
      clearSearchError: true,
    )));
  }

  /// Toggles the "الدواء غير موجود؟ أضفه يدوياً" flow — entering it drops any
  /// catalog selection and stops treating the name field as a search query;
  /// leaving it clears whatever was typed so the field goes back to search.
  void manualEntryToggled() {
    _searchDebounce?.cancel();
    _searchSession++;
    final enteringManualEntry = !state.formData.isManualEntry;
    emit(AddMedicineEditing(state.formData.copyWith(
      isManualEntry: enteringManualEntry,
      clearSelectedMedicine: true,
      nameQuery: enteringManualEntry ? state.formData.nameQuery : '',
      nameAr: enteringManualEntry ? state.formData.nameAr : '',
      activeIngredient: enteringManualEntry ? state.formData.activeIngredient : '',
      suggestions: const [],
      isSearching: false,
      clearSearchError: true,
    )));
  }

  void nameArChanged(String value) {
    emit(AddMedicineEditing(state.formData.copyWith(nameAr: value)));
  }

  void activeIngredientChanged(String value) {
    emit(AddMedicineEditing(state.formData.copyWith(activeIngredient: value)));
  }

  void quantityChanged(String value) {
    emit(AddMedicineEditing(state.formData.copyWith(quantity: value)));
  }

  void priceChanged(String value) {
    emit(AddMedicineEditing(state.formData.copyWith(price: value)));
  }

  void isAvailableChanged(bool value) {
    emit(AddMedicineEditing(state.formData.copyWith(isAvailable: value)));
  }

  Future<void> imageSelected(File imageFile) async {
    final session = ++_imageSession;

    emit(AddMedicineEditing(state.formData.copyWith(
      imageLocalPath: imageFile.path,
      isUploadingImage: true,
      clearImageError: true,
      clearImageUrl: true,
    )));

    final result = await _uploadImageUseCase(imageFile);
    if (session != _imageSession) return;

    switch (result) {
      case Success(:final data):
        emit(AddMedicineEditing(state.formData.copyWith(imageUrl: data, isUploadingImage: false)));
      case ApiError(:final failure):
        emit(AddMedicineEditing(
          state.formData.copyWith(isUploadingImage: false, imageError: failure.message),
        ));
    }
  }

  Future<void> save() async {
    final formData = state.formData;
    if (!formData.canSubmit) return;

    emit(AddMedicineSaving(formData));

    final result = formData.isManualEntry
        ? await _addPharmacyMedicineByNameUseCase(
            tradeName: formData.nameQuery.trim(),
            tradeNameAr: formData.nameAr.trim().isEmpty ? null : formData.nameAr.trim(),
            activeIngredient:
                formData.activeIngredient.trim().isEmpty ? null : formData.activeIngredient.trim(),
            price: formData.priceValue!,
            quantity: formData.quantityValue!,
            isAvailable: formData.isAvailable,
            imageUrl: formData.imageUrl,
          )
        : await _addByCatalogSelection(formData);

    switch (result) {
      case Success():
        emit(AddMedicineSuccess(formData));
      case ApiError(:final failure):
        emit(AddMedicineFailure(formData, failure.message));
    }
  }

  Future<ApiResult<void>> _addByCatalogSelection(AddMedicineFormData formData) {
    // The backend requires either medicine_id (the pharmacy's own general
    // catalog) or moh_medicine_id (a Ministry of Health entry) — which one
    // depends on where the selected suggestion came from.
    final selected = formData.selectedMedicine!;
    final isFromMoh = selected.type == 'moh';

    return _addPharmacyMedicineUseCase(
      medicineId: isFromMoh ? null : selected.id,
      mohMedicineId: isFromMoh ? selected.id : null,
      price: formData.priceValue!,
      quantity: formData.quantityValue!,
      isAvailable: formData.isAvailable,
      imageUrl: formData.imageUrl,
    );
  }
}
