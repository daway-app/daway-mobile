import '../../../../core/helpers/api_result.dart';
import '../entities/patient_auth_result.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository _repository;

  const VerifyOtpUseCase(this._repository);

  Future<ApiResult<PatientAuthResult>> call({
    required String phone,
    required String otp,
  }) {
    return _repository.verifyOtp(phone: phone, otp: otp);
  }
}
