class PharmacySignUpState {
  final String pharmacyName;
  final String phone;
  final String address;
  final String password;
  final double? latitude;
  final double? longitude;

  /// True right after the device location has been captured — the UI
  /// reacts by pushing the notifications permission step.
  final bool locationReady;
  final bool isFetchingLocation;
  final String? locationError;

  final bool isRegistering;
  final String? registerError;

  /// True right after the create-account API call succeeds — the account
  /// is pending admin approval at this point (no token/session yet), so
  /// the UI reacts by moving on to the location/notifications steps and
  /// eventually the pending-approval screen rather than logging in.
  final bool registered;

  const PharmacySignUpState({
    this.pharmacyName = '',
    this.phone = '',
    this.address = '',
    this.password = '',
    this.latitude,
    this.longitude,
    this.locationReady = false,
    this.isFetchingLocation = false,
    this.locationError,
    this.isRegistering = false,
    this.registerError,
    this.registered = false,
  });

  PharmacySignUpState copyWith({
    String? pharmacyName,
    String? phone,
    String? address,
    String? password,
    double? latitude,
    double? longitude,
    bool? locationReady,
    bool? isFetchingLocation,
    String? locationError,
    bool clearLocationError = false,
    bool? isRegistering,
    String? registerError,
    bool clearRegisterError = false,
    bool? registered,
  }) {
    return PharmacySignUpState(
      pharmacyName: pharmacyName ?? this.pharmacyName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      password: password ?? this.password,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationReady: locationReady ?? this.locationReady,
      isFetchingLocation: isFetchingLocation ?? this.isFetchingLocation,
      locationError: clearLocationError ? null : (locationError ?? this.locationError),
      isRegistering: isRegistering ?? this.isRegistering,
      registerError: clearRegisterError ? null : (registerError ?? this.registerError),
      registered: registered ?? this.registered,
    );
  }
}
