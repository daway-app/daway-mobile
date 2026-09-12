sealed class Failure {
  final String message;
  const Failure(this.message);
}

class ApiFailure extends Failure {
  final String? code;
  final int? statusCode;

  /// True when the backend rejected an OTP-verify call because it needs the
  /// full registration payload (name/birth_date/latitude/longitude) — the
  /// OTP itself is still valid and can be resent with that data added.
  final bool registrationRequired;

  const ApiFailure({
    required String message,
    this.code,
    this.statusCode,
    this.registrationRequired = false,
  }) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Device-level permission was denied or the underlying service (e.g. GPS)
/// is turned off — distinct from [ApiFailure] since there's no server involved.
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}
