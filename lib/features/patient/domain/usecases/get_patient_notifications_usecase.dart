import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../entities/patient_notification.dart';
import '../repositories/patient_notifications_repository.dart';

class GetPatientNotificationsUseCase {
  final PatientNotificationsRepository _repository;
  final SessionRepository _sessionRepository;

  const GetPatientNotificationsUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<List<PatientNotification>>> call() async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.getNotifications(token: session.token);
  }
}
