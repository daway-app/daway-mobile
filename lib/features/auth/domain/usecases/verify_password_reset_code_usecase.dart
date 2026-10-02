import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../repositories/password_reset_repository.dart';

/// The length of the verification code the backend sends.
const int passwordResetCodeLength = 6;

class VerifyPasswordResetCodeUseCase {
  final PasswordResetRepository _repository;

  const VerifyPasswordResetCodeUseCase(this._repository);

  /// On success, the proof the code was accepted (see
  /// [PasswordResetRepository.verifyCode]).
  Future<ApiResult<String>> call({required String phone, required String code}) {
    if (!RegExp('^[0-9]{$passwordResetCodeLength}\$').hasMatch(code)) {
      return Future.value(
        const ApiError(
          ValidationFailure('يرجى إدخال رمز التحقق المكوّن من $passwordResetCodeLength أرقام'),
        ),
      );
    }
    return _repository.verifyCode(phone: phone, code: code);
  }
}
