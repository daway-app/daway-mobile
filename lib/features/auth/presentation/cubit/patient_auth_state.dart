enum AuthDestination { home, notifications }

class PatientAuthState {
  final String phone;
  final bool otpSent;
  final bool isSendingOtp;
  final bool isVerifying;
  final String? errorMessage;
  final AuthDestination? destination;

  /// Set only when this cubit drives the sign-up form (name/birth date
  /// collected before the OTP is even sent) rather than the plain
  /// phone-only login. Their presence is what tells [verifyOtp] to send
  /// the full registration payload instead of just phone+otp.
  final String? name;
  final String? birthDate;
  final double? latitude;
  final double? longitude;

  /// True right after the backend rejects [verifyOtp] because it still
  /// needs the device location — the UI reacts by pushing the location
  /// permission step, then retries with the same OTP once it's captured.
  final bool needsLocation;
  final bool isFetchingLocation;
  final String? locationError;

  const PatientAuthState({
    this.phone = '',
    this.otpSent = false,
    this.isSendingOtp = false,
    this.isVerifying = false,
    this.errorMessage,
    this.destination,
    this.name,
    this.birthDate,
    this.latitude,
    this.longitude,
    this.needsLocation = false,
    this.isFetchingLocation = false,
    this.locationError,
  });

  bool get isSignUp => name != null;

  PatientAuthState copyWith({
    String? phone,
    bool? otpSent,
    bool? isSendingOtp,
    bool? isVerifying,
    String? errorMessage,
    bool clearError = false,
    AuthDestination? destination,
    String? name,
    String? birthDate,
    double? latitude,
    double? longitude,
    bool? needsLocation,
    bool? isFetchingLocation,
    String? locationError,
    bool clearLocationError = false,
  }) {
    return PatientAuthState(
      phone: phone ?? this.phone,
      otpSent: otpSent ?? this.otpSent,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifying: isVerifying ?? this.isVerifying,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      destination: destination ?? this.destination,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      needsLocation: needsLocation ?? this.needsLocation,
      isFetchingLocation: isFetchingLocation ?? this.isFetchingLocation,
      locationError: clearLocationError ? null : (locationError ?? this.locationError),
    );
  }
}
