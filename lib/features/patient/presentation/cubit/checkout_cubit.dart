import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../../../core/models/picked_location.dart';
import '../../domain/usecases/checkout_usecase.dart';
import '../../domain/usecases/create_patient_address_usecase.dart';
import '../../domain/usecases/get_patient_addresses_usecase.dart';
import '../../domain/usecases/get_patient_profile_usecase.dart';
import 'checkout_state.dart';

/// Drives "إتمام الطلب" on [PatientCartScreen]. Checkout needs a saved
/// address (`address_id` is required server-side) — [PatientAddressesScreen]'s
/// full address book doesn't exist yet, so this reuses the patient's default
/// saved address if there is one, or asks the screen to collect exactly one
/// (via the existing location picker) and creates it on the fly otherwise.
class CheckoutCubit extends Cubit<CheckoutState> {
  final GetPatientAddressesUseCase _getAddressesUseCase;
  final CreatePatientAddressUseCase _createAddressUseCase;
  final GetPatientProfileUseCase _getProfileUseCase;
  final CheckoutUseCase _checkoutUseCase;

  CheckoutCubit(
    this._getAddressesUseCase,
    this._createAddressUseCase,
    this._getProfileUseCase,
    this._checkoutUseCase,
  ) : super(const CheckoutIdle());

  Future<void> start() async {
    if (state is CheckoutInProgress) return;
    emit(const CheckoutInProgress());
    final result = await _getAddressesUseCase();
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        if (data.isEmpty) {
          emit(const CheckoutNeedsAddress());
          return;
        }
        final address = data.firstWhere((a) => a.isDefault, orElse: () => data.first);
        await _submit(address.id);
      case ApiError(:final failure):
        emit(CheckoutFailure(failure.message));
    }
  }

  Future<void> submitWithNewAddress(PickedLocation location) async {
    if (state is CheckoutInProgress) return;
    emit(const CheckoutInProgress());
    final profileResult = await _getProfileUseCase();
    if (isClosed) return;

    switch (profileResult) {
      case Success(:final data):
        final addressResult = await _createAddressUseCase(
          label: 'عنوان التوصيل',
          recipientName: data.name,
          phone: data.phone,
          address: location.address,
          latitude: location.latitude,
          longitude: location.longitude,
          // Only reached when the patient has no saved address yet (see
          // start()), so there's nothing to displace by defaulting this one.
          isDefault: true,
        );
        if (isClosed) return;
        switch (addressResult) {
          case Success(:final data):
            await _submit(data.id);
          case ApiError(:final failure):
            emit(CheckoutFailure(failure.message));
        }
      case ApiError(:final failure):
        emit(CheckoutFailure(failure.message));
    }
  }

  Future<void> _submit(int addressId) async {
    final result = await _checkoutUseCase(addressId: addressId);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(CheckoutSuccess(data));
      case ApiError(:final failure):
        emit(CheckoutFailure(failure.message));
    }
  }
}
