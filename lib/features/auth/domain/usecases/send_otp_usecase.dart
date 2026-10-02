import '../../../../core/helpers/api_result.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository _repository;

  const SendOtpUseCase(this._repository);

  Future<ApiResult<String?>> call({required String phone, String? name, String? birthDate}) {
    return _repository.sendOtp(phone: phone, name: name, birthDate: birthDate);
  }
}
