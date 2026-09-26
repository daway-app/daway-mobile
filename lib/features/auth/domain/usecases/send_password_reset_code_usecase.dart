import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../../core/helpers/validators.dart';
import '../repositories/password_reset_repository.dart';

class SendPasswordResetCodeUseCase {
  final PasswordResetRepository _repository;

  const SendPasswordResetCodeUseCase(this._repository);

  Future<ApiResult<void>> call({required String phone}) {
    if (!Validators.isValidLocalPhone(phone)) {
      return Future.value(
        const ApiError(ValidationFailure('يرجى إدخال رقم جوال صحيح مكوّن من 10 أرقام')),
      );
    }
    return _repository.sendCode(phone: phone);
  }
}
