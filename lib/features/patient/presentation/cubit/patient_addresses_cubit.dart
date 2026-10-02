import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../../../core/models/picked_location.dart';
import '../../domain/entities/patient_address.dart';
import '../../domain/usecases/create_patient_address_usecase.dart';
import '../../domain/usecases/delete_patient_address_usecase.dart';
import '../../domain/usecases/get_patient_addresses_usecase.dart';
import '../../domain/usecases/get_patient_profile_usecase.dart';
import '../../domain/usecases/update_patient_address_usecase.dart';
import 'patient_addresses_state.dart';

/// Drives "عناويني". The screen has no name/phone fields of its own (see
/// PatientAddressesScreen's doc comment) — new addresses borrow the
/// patient's own profile name/phone, and edits keep whatever the address
/// already had, only replacing the picked location.
class PatientAddressesCubit extends Cubit<PatientAddressesState> {
  final GetPatientAddressesUseCase _getAddressesUseCase;
  final CreatePatientAddressUseCase _createAddressUseCase;
  final UpdatePatientAddressUseCase _updateAddressUseCase;
  final GetPatientProfileUseCase _getProfileUseCase;
  final DeletePatientAddressUseCase _deleteAddressUseCase;

  PatientAddressesCubit(
    this._getAddressesUseCase,
    this._createAddressUseCase,
    this._updateAddressUseCase,
    this._getProfileUseCase,
    this._deleteAddressUseCase,
  ) : super(const PatientAddressesLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const PatientAddressesLoading());
    final result = await _getAddressesUseCase();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(PatientAddressesLoaded(data));
      case ApiError(:final failure):
        emit(PatientAddressesLoadFailure(failure.message));
    }
  }

  static String _labelFor(int index) => switch (index) {
        0 => 'المنزل',
        1 => 'العمل',
        _ => 'عنوان ${index + 1}',
      };

  /// Returns null on success (and reloads the list), or a user-facing error
  /// message — same contract as MedicineDetailCubit.toggleFavorite. Guarded
  /// by [PatientAddressesLoaded.isSubmitting] so a fast double-tap on "أضف
  /// عنوان" can't fire two overlapping creates (which — before this guard —
  /// could also race on [current]'s pre-await address count and label both
  /// new addresses identically).
  ///
  /// [label] is the name the patient picked (منزل / عمل / آخر); when null
  /// the address gets an automatic one.
  Future<String?> addAddress(PickedLocation location, {String? label}) async {
    final current = state;
    if (current is! PatientAddressesLoaded || current.isSubmitting) return null;
    emit(current.copyWith(isSubmitting: true));

    final profileResult = await _getProfileUseCase();
    if (isClosed) return null;

    switch (profileResult) {
      case Success(:final data):
        final result = await _createAddressUseCase(
          label: label ?? _labelFor(current.addresses.length),
          recipientName: data.name,
          phone: data.phone,
          address: location.address,
          latitude: location.latitude,
          longitude: location.longitude,
          // Only the first saved address becomes the default automatically —
          // later ones don't displace it (this screen has no "set default"
          // affordance yet to let the patient choose otherwise).
          isDefault: current.addresses.isEmpty,
        );
        if (isClosed) return null;
        switch (result) {
          case Success():
            await load();
            return null;
          case ApiError(:final failure):
            emit(current.copyWith(isSubmitting: false));
            return failure.message;
        }
      case ApiError(:final failure):
        emit(current.copyWith(isSubmitting: false));
        return failure.message;
    }
  }

  /// Same contract and re-entrancy guard as [addAddress]. A null [location]
  /// keeps the saved position (a rename only); a null [label] keeps the name.
  Future<String?> updateAddress(
    PatientAddress existing,
    PickedLocation? location, {
    String? label,
  }) async {
    final current = state;
    if (current is! PatientAddressesLoaded || current.isSubmitting) return null;
    emit(current.copyWith(isSubmitting: true));

    final result = await _updateAddressUseCase(
      addressId: existing.id,
      label: label ?? existing.label,
      recipientName: existing.recipientName,
      phone: existing.phone,
      address: location?.address ?? existing.address,
      latitude: location?.latitude ?? existing.latitude,
      longitude: location?.longitude ?? existing.longitude,
      isDefault: existing.isDefault,
    );
    if (isClosed) return null;

    switch (result) {
      case Success():
        await load();
        return null;
      case ApiError(:final failure):
        emit(current.copyWith(isSubmitting: false));
        return failure.message;
    }
  }

  /// Deletes [address] and reloads. Returns null on success, or a user-facing
  /// error message. Same re-entrancy guard as [addAddress].
  Future<String?> deleteAddress(PatientAddress address) async {
    final current = state;
    if (current is! PatientAddressesLoaded || current.isSubmitting) return null;
    emit(current.copyWith(isSubmitting: true));

    final result = await _deleteAddressUseCase(address.id);
    if (isClosed) return null;

    switch (result) {
      case Success():
        await load();
        return null;
      case ApiError(:final failure):
        emit(current.copyWith(isSubmitting: false));
        return failure.message;
    }
  }
}
