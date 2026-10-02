import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../entities/patient_address.dart';
import '../repositories/patient_addresses_repository.dart';

class GetPatientAddressesUseCase {
  final PatientAddressesRepository _repository;
  final SessionRepository _sessionRepository;

  const GetPatientAddressesUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<List<PatientAddress>>> call() async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.getAddresses(token: session.token);
  }
}
