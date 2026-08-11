class PharmacyAuthState {
  final bool isLoggingIn;
  final String? errorMessage;
  final String? token;

  const PharmacyAuthState({
    this.isLoggingIn = false,
    this.errorMessage,
    this.token,
  });

  PharmacyAuthState copyWith({
    bool? isLoggingIn,
    String? errorMessage,
    bool clearError = false,
    String? token,
  }) {
    return PharmacyAuthState(
      isLoggingIn: isLoggingIn ?? this.isLoggingIn,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      token: token ?? this.token,
    );
  }
}
