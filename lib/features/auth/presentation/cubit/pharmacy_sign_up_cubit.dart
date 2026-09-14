import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../../patient/domain/usecases/get_current_location_usecase.dart';
import '../../domain/usecases/register_pharmacy_usecase.dart';
import 'pharmacy_sign_up_state.dart';

/// Drives the pharmacy account-creation screen — collects the form fields,
/// then calls the create-account API (which always leaves the account
/// pending admin approval) before moving on to the location/notifications
/// steps.
class PharmacySignUpCubit extends Cubit<PharmacySignUpState> {
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;
  final RegisterPharmacyUseCase _registerPharmacyUseCase;

  PharmacySignUpCubit(this._getCurrentLocationUseCase, this._registerPharmacyUseCase)
      : super(const PharmacySignUpState());

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

  Future<void> register() async {
    emit(state.copyWith(isRegistering: true, clearRegisterError: true));

    final result = await _registerPharmacyUseCase(
      pharmacyName: state.pharmacyName,
      phone: state.phone,
      region: state.address,
      password: state.password,
    );

    switch (result) {
      case Success():
        emit(state.copyWith(isRegistering: false, registered: true));
      case ApiError(:final failure):
        emit(state.copyWith(isRegistering: false, registerError: failure.message));
    }
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
