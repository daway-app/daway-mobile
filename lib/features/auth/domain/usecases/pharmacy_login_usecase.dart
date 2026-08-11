import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../entities/pharmacy_auth_result.dart';
import '../repositories/auth_repository.dart';

class PharmacyLoginUseCase {
  final AuthRepository _repository;

  const PharmacyLoginUseCase(this._repository);

  Future<ApiResult<PharmacyAuthResult>> call({
    required String pharmacyId,
    required String password,
  }) {
    if (pharmacyId.trim().isEmpty || password.isEmpty) {
      return Future.value(
        const ApiError(ValidationFailure('يرجى إدخال معرف الصيدلية وكلمة المرور')),
      );
    }
    return _repository.pharmacyLogin(pharmacyId: pharmacyId, password: password);
  }
}
