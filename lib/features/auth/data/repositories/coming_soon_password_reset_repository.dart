import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../domain/repositories/password_reset_repository.dart';

/// Stands in for the password-reset API until the backend has one: it probed
/// as absent on 2026-09-26 (only the signed-in `POST /pharmacy/change-password`
/// exists). Every call answers [ComingSoonFailure], which the screens show as
/// "قريباً" — nothing is pretended to have been sent, verified or changed.
///
/// When the endpoints exist, replace this with a real repository over a remote
/// data source and register that instead in the DI setup.
class ComingSoonPasswordResetRepository implements PasswordResetRepository {
  const ComingSoonPasswordResetRepository();

  @override
  Future<ApiResult<void>> sendCode({required String phone}) async =>
      const ApiError(ComingSoonFailure());

  @override
  Future<ApiResult<String>> verifyCode({required String phone, required String code}) async =>
      const ApiError(ComingSoonFailure());

  @override
  Future<ApiResult<void>> resetPassword({
    required String phone,
    required String resetToken,
    required String password,
  }) async => const ApiError(ComingSoonFailure());
}
