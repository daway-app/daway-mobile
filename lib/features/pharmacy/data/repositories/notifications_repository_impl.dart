import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../../core/helpers/json_list_extractor.dart';
import '../../../../core/helpers/sort_by_date.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';
import '../models/notification_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _remoteDataSource;

  const NotificationsRepositoryImpl(this._remoteDataSource);

  /// `GET /notifications` returns the page of notifications plus its own
  /// `unread_count` — used as-is (rather than tallied from the page) since
  /// the page can be a partial (paginated) view, same reasoning as
  /// PharmacyInquiriesRepositoryImpl.getInquiries. One malformed
  /// notification record is skipped rather than failing the whole list.
  @override
  Future<ApiResult<NotificationsOverview>> getNotifications({
    required String token,
  }) async {
    try {
      final response = await _remoteDataSource.getNotifications(token: token);
      final body = response.data as Map<String, dynamic>;
      final notificationsJson = extractJsonList(
        body,
        source: 'GET /notifications',
      );

      final notifications = <AppNotification>[];
      for (final json in notificationsJson) {
        try {
          notifications.add(
            NotificationModel.fromJson(json as Map<String, dynamic>).toEntity(),
          );
        } catch (_) {
          // Skip just this record.
        }
      }
      sortByDateDescending(notifications, (n) => n.createdAt);

      // Isolated in its own try/catch, same reasoning as
      // PharmacyRatingsRepositoryImpl's totalCount: unread_count is a
      // best-effort enrichment on top of the notifications list that's
      // already been fully parsed above, so a malformed shape here should
      // fall back to a client-side tally instead of discarding that list.
      int unreadCount;
      try {
        unreadCount = (body['unread_count'] as num).toInt();
      } catch (_) {
        unreadCount = notifications.where((n) => !n.isRead).length;
      }

      return Success(
        NotificationsOverview(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> markAllAsRead({required String token}) async {
    try {
      await _remoteDataSource.markAllAsRead(token: token);
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> markAsRead({
    required String token,
    required int notificationId,
  }) async {
    try {
      await _remoteDataSource.markAsRead(
        token: token,
        notificationId: notificationId,
      );
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
