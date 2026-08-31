import '../../../../core/helpers/api_result.dart';
import '../entities/notification.dart';

abstract class NotificationsRepository {
  Future<ApiResult<NotificationsOverview>> getNotifications({
    required String token,
  });

  Future<ApiResult<void>> markAllAsRead({required String token});

  Future<ApiResult<void>> markAsRead({
    required String token,
    required int notificationId,
  });
}
