import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../../patient/domain/usecases/get_current_location_usecase.dart';
import 'pharmacy_sign_up_state.dart';

/// Drives the pharmacy account-creation screen. There is no pharmacy
/// registration endpoint yet, so [detailsChanged] just holds the entered
/// fields for the eventual create-account call once that API is ready;
/// today the form only carries the pharmacy through the location and
/// notifications permission steps, mirroring the patient sign-up flow.
class PharmacySignUpCubit extends Cubit<PharmacySignUpState> {
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;

  PharmacySignUpCubit(this._getCurrentLocationUseCase) : super(const PharmacySignUpState());

  void detailsChanged({
    required String pharmacyName,
    required String phone,
    required String address,
    required String password,
  }) {
    emit(state.copyWith(
      pharmacyName: pharmacyName,
      phone: phone,
      address: address,
      password: password,
    ));
  }

  Future<void> useCurrentLocation() async {
    emit(state.copyWith(isFetchingLocation: true, clearLocationError: true));

    final result = await _getCurrentLocationUseCase();
    switch (result) {
      case Success(:final data):
        emit(state.copyWith(
          isFetchingLocation: false,
          latitude: data.latitude,
          longitude: data.longitude,
          locationReady: true,
        ));
      case ApiError(:final failure):
        emit(state.copyWith(isFetchingLocation: false, locationError: failure.message));
    }
  }
}
