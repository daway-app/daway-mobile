import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../entities/patient_address.dart';
import '../repositories/patient_addresses_repository.dart';

class CreatePatientAddressUseCase {
  final PatientAddressesRepository _repository;
  final SessionRepository _sessionRepository;

  const CreatePatientAddressUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<PatientAddress>> call({
    required String label,
    required String recipientName,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    bool isDefault = true,
  }) async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.createAddress(
      token: session.token,
      label: label,
      recipientName: recipientName,
      phone: phone,
      address: address,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );
  }
}
