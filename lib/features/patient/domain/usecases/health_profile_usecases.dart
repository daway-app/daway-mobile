import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../entities/patient_health_profile.dart';
import '../repositories/health_profile_repository.dart';

const _sessionExpired = ApiError<PatientHealthProfile>(
  ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
);

class GetHealthProfileUseCase {
  final HealthProfileRepository _repository;
  final SessionRepository _sessionRepository;

  const GetHealthProfileUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<PatientHealthProfile>> call() async {
    final session = await _sessionRepository.getSession();
    if (session == null) return _sessionExpired;
    return _repository.getHealthProfile(token: session.token);
  }
}

class UpdateHealthProfileUseCase {
  final HealthProfileRepository _repository;
  final SessionRepository _sessionRepository;

  const UpdateHealthProfileUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<PatientHealthProfile>> call(PatientHealthProfile profile) async {
    final session = await _sessionRepository.getSession();
    if (session == null) return _sessionExpired;
    return _repository.updateHealthProfile(token: session.token, profile: profile);
  }
}
