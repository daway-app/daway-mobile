import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../entities/patient_profile.dart';
import '../repositories/patient_profile_repository.dart';

/// Reads the auth token from the local session (like [UpdatePatientProfileUseCase]
/// does) so the cubit never has to know where the token comes from.
class GetPatientProfileUseCase {
  final PatientProfileRepository _repository;
  final SessionRepository _sessionRepository;

  const GetPatientProfileUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<PatientProfile>> call() async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.getProfile(token: session.token);
  }
}
