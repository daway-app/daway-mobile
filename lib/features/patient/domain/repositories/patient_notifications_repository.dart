import '../../../../core/helpers/api_result.dart';
import '../entities/patient_notification.dart';

abstract class PatientNotificationsRepository {
  Future<ApiResult<List<PatientNotification>>> getNotifications({required String token});
}
