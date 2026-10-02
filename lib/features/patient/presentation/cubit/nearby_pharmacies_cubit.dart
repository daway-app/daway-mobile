import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/nearby_pharmacy.dart';
import '../../domain/usecases/get_current_location_usecase.dart';
import '../../domain/usecases/get_nearby_pharmacies_usecase.dart';
import '../../domain/usecases/get_pharmacy_working_hours_usecase.dart';
import 'nearby_pharmacies_state.dart';

class NearbyPharmaciesCubit extends Cubit<NearbyPharmaciesState> {
  final GetNearbyPharmaciesUseCase _getNearbyPharmaciesUseCase;
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;
  final GetPharmacyWorkingHoursUseCase _getPharmacyWorkingHoursUseCase;

  NearbyPharmaciesCubit(
    this._getNearbyPharmaciesUseCase,
    this._getCurrentLocationUseCase,
    this._getPharmacyWorkingHoursUseCase,
  ) : super(const NearbyPharmaciesLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const NearbyPharmaciesLoading());

    // Best-effort, same reasoning as MedicineDetailCubit: a denied/
    // unavailable location just means the list isn't sorted by distance.
    final locationResult = await _getCurrentLocationUseCase();
    final location = switch (locationResult) {
      Success(:final data) => data,
      ApiError() => null,
    };

    final result = await _getNearbyPharmaciesUseCase(
      userLatitude: location?.latitude,
      userLongitude: location?.longitude,
    );
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        emit(NearbyPharmaciesLoaded(
          pharmacies: data,
          userLatitude: location?.latitude,
          userLongitude: location?.longitude,
        ));
      case ApiError(:final failure):
        emit(NearbyPharmaciesLoadFailure(failure.message));
    }
  }

  void searchChanged(String query) {
    final current = state;
    if (current is! NearbyPharmaciesLoaded) return;
    emit(current.copyWith(query: query));
  }

  /// Opens the detail sheet immediately with what's already known, then
  /// fills in the working-hours line once it arrives (or leaves it out on
  /// failure — a secondary enrichment, not worth failing the selection
  /// over).
  Future<void> selectPharmacy(NearbyPharmacy pharmacy) async {
    final current = state;
    if (current is! NearbyPharmaciesLoaded) return;

    emit(current.copyWith(
      selectedPharmacy: pharmacy,
      isLoadingHours: true,
      clearWorkingHours: true,
    ));

    final result = await _getPharmacyWorkingHoursUseCase(pharmacy.id);
    if (isClosed) return;

    // The selection may have moved on (a different pharmacy tapped, or the
    // sheet dismissed) while this was in flight.
    final latest = state;
    if (latest is! NearbyPharmaciesLoaded || latest.selectedPharmacy?.id != pharmacy.id) {
      return;
    }

    switch (result) {
      case Success(:final data):
        // `data` itself may legitimately be null (no parseable hours) —
        // `clearWorkingHours` makes that explicit instead of relying on
        // copyWith's `??` silently keeping a stale previous value.
        emit(latest.copyWith(
          isLoadingHours: false,
          selectedWorkingHours: data,
          clearWorkingHours: data == null,
        ));
      case ApiError():
        emit(latest.copyWith(isLoadingHours: false));
    }
  }

  void clearSelection() {
    final current = state;
    if (current is! NearbyPharmaciesLoaded) return;
    emit(current.copyWith(clearSelection: true));
  }
}
