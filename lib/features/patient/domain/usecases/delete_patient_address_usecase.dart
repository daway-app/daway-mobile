import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../repositories/patient_addresses_repository.dart';

class DeletePatientAddressUseCase {
  final PatientAddressesRepository _repository;
  final SessionRepository _sessionRepository;

  const DeletePatientAddressUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<void>> call(int addressId) async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.deleteAddress(token: session.token, addressId: addressId);
  }
}
