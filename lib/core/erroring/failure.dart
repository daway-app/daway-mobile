sealed class Failure {
  final String message;
  const Failure(this.message);
}

class ApiFailure extends Failure {
  final String? code;
  final int? statusCode;

  const ApiFailure({required String message, this.code, this.statusCode})
      : super(message);
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
