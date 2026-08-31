import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../repositories/notifications_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationsRepository _repository;
  final SessionRepository _sessionRepository;

  const MarkNotificationReadUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<void>> call({required int notificationId}) async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.markAsRead(
      token: session.token,
      notificationId: notificationId,
    );
  }
}
