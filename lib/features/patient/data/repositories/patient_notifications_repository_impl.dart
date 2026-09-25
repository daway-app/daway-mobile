import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../../core/helpers/paginated_fetch.dart';
import '../../../../core/helpers/sort_by_date.dart';
import '../../domain/entities/patient_notification.dart';
import '../../domain/repositories/patient_notifications_repository.dart';
import '../datasources/patient_notifications_remote_data_source.dart';
import '../models/patient_notification_model.dart';

class PatientNotificationsRepositoryImpl implements PatientNotificationsRepository {
  final PatientNotificationsRemoteDataSource _remoteDataSource;

  const PatientNotificationsRepositoryImpl(this._remoteDataSource);

  /// One malformed notification record is skipped rather than failing the
  /// whole list; the rest are shown newest first. But a response whose
  /// records ALL fail to parse is a changed API contract, not an empty inbox,
  /// so that is reported as an error instead of the "no notifications" state.
  @override
  Future<ApiResult<List<PatientNotification>>> getNotifications({
    required String token,
  }) async {
    try {
      const source = 'GET /notifications';
      final notificationsJson = await fetchAllPages(
        source: source,
        fetchPage: (page) async =>
            (await _remoteDataSource.getNotifications(token: token, page: page)).data,
      );

      final notifications = <PatientNotification>[];
      for (final json in notificationsJson) {
        try {
          notifications.add(
            PatientNotificationModel.fromJson(json as Map<String, dynamic>).toEntity(),
          );
        } catch (_) {
          // Skip just this record.
        }
      }
      if (notificationsJson.isNotEmpty && notifications.isEmpty) {
        throw FormatException(
          'None of the ${notificationsJson.length} $source records could be parsed',
        );
      }
      sortByDateDescending(notifications, (n) => n.createdAt);
      return Success(notifications);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
