import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/medicine_detail.dart';
import '../../domain/entities/medicine_pharmacy_offer.dart';
import '../../domain/usecases/add_cart_item_usecase.dart';
import '../../domain/usecases/add_favorite_medicine_usecase.dart';
import '../../domain/usecases/get_current_location_usecase.dart';
import '../../domain/usecases/get_favorite_medicines_usecase.dart';
import '../../domain/usecases/get_medicine_detail_usecase.dart';
import '../../domain/usecases/get_medicine_pharmacies_usecase.dart';
import '../../domain/usecases/remove_favorite_medicine_usecase.dart';
import 'medicine_detail_state.dart';

class MedicineDetailCubit extends Cubit<MedicineDetailState> {
  final int medicineId;
  final GetMedicineDetailUseCase _getMedicineDetailUseCase;
  final GetMedicinePharmaciesUseCase _getMedicinePharmaciesUseCase;
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;
  final GetFavoriteMedicinesUseCase _getFavoriteMedicinesUseCase;
  final AddFavoriteMedicineUseCase _addFavoriteMedicineUseCase;
  final RemoveFavoriteMedicineUseCase _removeFavoriteMedicineUseCase;
  final AddCartItemUseCase _addCartItemUseCase;

  MedicineDetailCubit(
    this.medicineId,
    this._getMedicineDetailUseCase,
    this._getMedicinePharmaciesUseCase,
    this._getCurrentLocationUseCase,
    this._getFavoriteMedicinesUseCase,
    this._addFavoriteMedicineUseCase,
    this._removeFavoriteMedicineUseCase,
    this._addCartItemUseCase,
  ) : super(const MedicineDetailLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const MedicineDetailLoading());

    // Best-effort: a denied/unavailable location just means the pharmacy
    // rows come back without a distance, not a failed screen — same
    // reasoning as PharmacyDashboardRepositoryImpl's secondary fetches.
    final locationResult = await _getCurrentLocationUseCase();
    final location = switch (locationResult) {
      Success(:final data) => data,
      ApiError() => null,
    };

    final medicineResult = await _getMedicineDetailUseCase(
      medicineId: medicineId,
      latitude: location?.latitude,
      longitude: location?.longitude,
    );
    if (isClosed) return;

    final MedicineDetail medicine;
    switch (medicineResult) {
      case Success(:final data):
        medicine = data;
      case ApiError(:final failure):
        emit(MedicineDetailLoadFailure(failure.message));
        return;
    }

    var pharmaciesResult = await _getMedicinePharmaciesUseCase(
      medicineId: medicineId,
      latitude: location?.latitude,
      longitude: location?.longitude,
    );
    if (isClosed) return;

    // With coordinates the backend only lists pharmacies within its search
    // radius, so a patient far from every pharmacy (or an emulator sitting in
    // California) would see "no pharmacies" for a medicine that is in stock.
    // Ask again without coordinates: the pharmacies show, just without a
    // distance.
    if (location != null &&
        (pharmaciesResult is ApiError ||
            (pharmaciesResult is Success<List<MedicinePharmacyOffer>> &&
                pharmaciesResult.data.isEmpty))) {
      pharmaciesResult = await _getMedicinePharmaciesUseCase(medicineId: medicineId);
      if (isClosed) return;
    }

    // The pharmacy list is secondary content here too: a medicine that
    // fetched fine still shows, just with an empty "choose a pharmacy" list
    // instead of the whole screen failing.
    final pharmacies = switch (pharmaciesResult) {
      Success(:final data) => data,
      ApiError() => const <MedicinePharmacyOffer>[],
    };

    // Also best-effort, and for the same reason as location: GET
    // /medicines/{id} has no "is this saved" field of its own, so the only
    // way to know the real starting isFavorite is to check the patient's
    // favorites list — a denied/failed fetch just leaves it at the
    // conservative default (false) instead of failing the screen.
    final favoritesResult = await _getFavoriteMedicinesUseCase();
    if (isClosed) return;
    final isFavorite = switch (favoritesResult) {
      Success(:final data) => data.any((favorite) => favorite.medicineId == medicineId),
      ApiError() => false,
    };

    emit(MedicineDetailLoaded(medicine: medicine, pharmacies: pharmacies, isFavorite: isFavorite));
  }

  /// Adds one of [offer] to the cart. Returns null on success, or a
  /// user-facing error message — same contract as [toggleFavorite].
  Future<String?> addToCart(MedicinePharmacyOffer offer) async {
    final result = await _addCartItemUseCase(
      pharmacyMedicineId: offer.pharmacyMedicineId,
      pharmacyId: offer.pharmacyId,
      medicineId: medicineId,
    );
    return switch (result) {
      Success() => null,
      ApiError(:final failure) => failure.message,
    };
  }

  /// Returns null on success, or a user-facing error message on failure —
  /// same contract as PharmacyInquiriesCubit.updateStatus, so the screen can
  /// show a snackbar without the cubit owning UI feedback.
  Future<String?> toggleFavorite() async {
    final current = state;
    if (current is! MedicineDetailLoaded || current.isTogglingFavorite) return null;

    emit(current.copyWith(isTogglingFavorite: true));
    final result = current.isFavorite
        ? await _removeFavoriteMedicineUseCase(medicineId)
        : await _addFavoriteMedicineUseCase(medicineId);
    if (isClosed) return null;

    switch (result) {
      case Success():
        emit(current.copyWith(isFavorite: !current.isFavorite, isTogglingFavorite: false));
        return null;
      case ApiError(:final failure):
        emit(current.copyWith(isTogglingFavorite: false));
        return failure.message;
    }
  }
}
