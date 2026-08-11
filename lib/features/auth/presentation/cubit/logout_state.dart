class LogoutState {
  final bool isLoggingOut;
  final bool isLoggedOut;

  const LogoutState({
    this.isLoggingOut = false,
    this.isLoggedOut = false,
  });

  LogoutState copyWith({
    bool? isLoggingOut,
    bool? isLoggedOut,
  }) {
    return LogoutState(
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
    );
  }
}
