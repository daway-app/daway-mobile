/// Where a pharmacy is in resetting its password; each step is a screen.
enum PasswordResetStep { phone, code, newPassword, done }

class PasswordResetState {
  final PasswordResetStep step;

  /// The number the code was sent to, once it was.
  final String phone;

  /// What the backend gave back for the accepted code, to present with the new
  /// password; empty until the code is accepted.
  final String resetToken;

  /// A request is on its way.
  final bool isBusy;

  /// Why the last step failed, for the screen to show by its field; cleared
  /// when the next step starts.
  final String? errorMessage;

  /// A message for a snackbar rather than by a field — the "قريباً" of a step
  /// the backend cannot do yet. Cleared when the next step starts.
  final String? notice;

  const PasswordResetState({
    this.step = PasswordResetStep.phone,
    this.phone = '',
    this.resetToken = '',
    this.isBusy = false,
    this.errorMessage,
    this.notice,
  });

  PasswordResetState copyWith({
    PasswordResetStep? step,
    String? phone,
    String? resetToken,
    bool? isBusy,
    String? errorMessage,
    String? notice,
    bool clearMessages = false,
  }) {
    return PasswordResetState(
      step: step ?? this.step,
      phone: phone ?? this.phone,
      resetToken: resetToken ?? this.resetToken,
      isBusy: isBusy ?? this.isBusy,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      notice: clearMessages ? null : (notice ?? this.notice),
    );
  }
}
