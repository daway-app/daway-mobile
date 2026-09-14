import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../repositories/auth_repository.dart';

class RegisterPharmacyUseCase {
  final AuthRepository _repository;

  const RegisterPharmacyUseCase(this._repository);

  Future<ApiResult<void>> call({
    required String pharmacyName,
    required String phone,
    required String region,
    required String password,
  }) {
    if (pharmacyName.trim().isEmpty || phone.trim().isEmpty || region.trim().isEmpty) {
      return Future.value(
        const ApiError(ValidationFailure('يرجى تعبئة جميع الحقول المطلوبة')),
      );
    }
    if (password.length < 8) {
      return Future.value(
        const ApiError(ValidationFailure('كلمة المرور يجب أن تكون 8 أحرف على الأقل')),
      );
    }
    return _repository.registerPharmacy(
      pharmacyName: pharmacyName.trim(),
      phone: phone.trim(),
      region: region.trim(),
      password: password,
    );
  }
}
