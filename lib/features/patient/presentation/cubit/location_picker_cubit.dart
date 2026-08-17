import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/usecases/get_current_location_usecase.dart';
import '../../domain/usecases/reverse_geocode_usecase.dart';
import '../../domain/usecases/search_address_usecase.dart';
import 'location_picker_state.dart';

/// Bundles the runtime navigation arguments into a single object since
/// get_it's factory-with-params registration only accepts one param.
class LocationPickerParams {
  final double initialLatitude;
  final double initialLongitude;
  final String? initialAddress;

  const LocationPickerParams({
    required this.initialLatitude,
    required this.initialLongitude,
    this.initialAddress,
  });
}

class LocationPickerCubit extends Cubit<LocationPickerState> {
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;
  final ReverseGeocodeUseCase _reverseGeocodeUseCase;
  final SearchAddressUseCase _searchAddressUseCase;

  LocationPickerCubit(
    this._getCurrentLocationUseCase,
    this._reverseGeocodeUseCase,
    this._searchAddressUseCase, {
    required double initialLatitude,
    required double initialLongitude,
    String? initialAddress,
  }) : super(LocationPickerState(
          latitude: initialLatitude,
          longitude: initialLongitude,
          address: initialAddress,
        ));

  /// Called while the user drags the map (the pin itself never moves — the
  /// map does), reporting the coordinates currently under the fixed center pin.
  void pinMoved(double latitude, double longitude) {
    emit(state.copyWith(latitude: latitude, longitude: longitude, clearError: true));
  }

  Future<void> resolveAddressForCurrentPin() async {
    emit(state.copyWith(isResolvingAddress: true));
    final result = await _reverseGeocodeUseCase(
      latitude: state.latitude,
      longitude: state.longitude,
    );
    switch (result) {
      case Success(:final data):
        // A blank result (no placemark for these coordinates) must not wipe
        // out an address that was already showing — copyWith's `address ??
        // this.address` treats null as "leave it as-is", empty string as a
        // real value, so an empty result is passed through as null on purpose.
        emit(state.copyWith(
          address: data.isNotEmpty ? data : null,
          isResolvingAddress: false,
        ));
      case ApiError():
        emit(state.copyWith(isResolvingAddress: false));
    }
  }

  Future<void> useCurrentLocation() async {
    emit(state.copyWith(isLocating: true, clearError: true));
    final result = await _getCurrentLocationUseCase();
    switch (result) {
      case Success(:final data):
        emit(state.copyWith(
          latitude: data.latitude,
          longitude: data.longitude,
          address: data.address.isNotEmpty ? data.address : null,
          isLocating: false,
        ));
      case ApiError(:final failure):
        emit(state.copyWith(isLocating: false, errorMessage: failure.message));
    }
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    emit(state.copyWith(isSearching: true, clearError: true));
    final result = await _searchAddressUseCase(query.trim());
    switch (result) {
      case Success(:final data):
        emit(state.copyWith(
          latitude: data.latitude,
          longitude: data.longitude,
          address: data.address.isNotEmpty ? data.address : null,
          isSearching: false,
        ));
      case ApiError(:final failure):
        emit(state.copyWith(isSearching: false, errorMessage: failure.message));
    }
  }
}
