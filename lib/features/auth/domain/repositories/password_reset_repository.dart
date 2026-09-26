import '../../../../core/helpers/api_result.dart';

/// Resetting a pharmacy's forgotten password: a code is sent to the phone
/// number the pharmacy registered with, the pharmacy types it in, and only then
/// chooses the new password.
///
/// The backend has no endpoint for any of this yet, so the app is wired to
/// `ComingSoonPasswordResetRepository` until one exists — when it does, that
/// is the one class to replace.
abstract class PasswordResetRepository {
  /// Sends a verification code to [phone].
  Future<ApiResult<void>> sendCode({required String phone});

  /// Checks the [code] sent to [phone]. On success returns the proof that it
  /// was accepted, which [resetPassword] must hand back — what that is (a
  /// token, or the code itself) is up to the backend.
  Future<ApiResult<String>> verifyCode({required String phone, required String code});

  /// Sets the new [password] for the pharmacy behind [phone], with the
  /// [resetToken] that [verifyCode] returned.
  Future<ApiResult<void>> resetPassword({
    required String phone,
    required String resetToken,
    required String password,
  });
}
