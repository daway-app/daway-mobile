import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../entities/pharmacy_inquiry.dart';
import '../repositories/patient_inquiries_repository.dart';

class GetPatientInquiriesUseCase {
  final PatientInquiriesRepository _repository;
  final SessionRepository _sessionRepository;

  const GetPatientInquiriesUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<List<PharmacyInquiry>>> call() async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.getInquiries(token: session.token);
  }
}
