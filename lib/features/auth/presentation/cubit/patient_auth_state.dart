enum AuthDestination { profile, home }

class PatientAuthState {
  final String phone;
  final bool agreedToTerms;
  final bool otpSent;
  final bool isSendingOtp;
  final bool isVerifying;
  final String? errorMessage;
  final AuthDestination? destination;

  const PatientAuthState({
    this.phone = '',
    this.agreedToTerms = false,
    this.otpSent = false,
    this.isSendingOtp = false,
    this.isVerifying = false,
    this.errorMessage,
    this.destination,
  });

  PatientAuthState copyWith({
    String? phone,
    bool? agreedToTerms,
    bool? otpSent,
    bool? isSendingOtp,
    bool? isVerifying,
    String? errorMessage,
    bool clearError = false,
    AuthDestination? destination,
  }) {
    return PatientAuthState(
      phone: phone ?? this.phone,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      otpSent: otpSent ?? this.otpSent,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifying: isVerifying ?? this.isVerifying,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      destination: destination ?? this.destination,
    );
  }
}
