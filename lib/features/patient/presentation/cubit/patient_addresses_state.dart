import '../../domain/entities/patient_address.dart';

sealed class PatientAddressesState {
  const PatientAddressesState();
}

class PatientAddressesLoading extends PatientAddressesState {
  const PatientAddressesLoading();
}

class PatientAddressesLoadFailure extends PatientAddressesState {
  final String message;

  const PatientAddressesLoadFailure(this.message);
}

class PatientAddressesLoaded extends PatientAddressesState {
  final List<PatientAddress> addresses;

  /// An add/edit request is in flight — disables the "أضف عنوان" button and
  /// every edit chip so a fast double-tap can't fire two overlapping writes.
  final bool isSubmitting;

  const PatientAddressesLoaded(this.addresses, {this.isSubmitting = false});

  PatientAddressesLoaded copyWith({List<PatientAddress>? addresses, bool? isSubmitting}) {
    return PatientAddressesLoaded(
      addresses ?? this.addresses,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
