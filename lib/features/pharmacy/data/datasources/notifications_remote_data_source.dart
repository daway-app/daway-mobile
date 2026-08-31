import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

class NotificationsRemoteDataSource {
  final Dio _dio;

  const NotificationsRemoteDataSource(this._dio);

  /// `per_page: 100` caps the page itself, same tradeoff as
  /// PharmacyInquiriesRemoteDataSource.getInquiries — fine for the list and
  /// for a pharmacy with under 100 notifications, but `unread_count` (read
  /// from the backend's own field, not tallied from this page) stays
  /// correct regardless.
  Future<Response<dynamic>> getNotifications({required String token}) {
    return _dio.get(
      ApiConstants.notifications,
      queryParameters: {'per_page': 100},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response<dynamic>> markAllAsRead({required String token}) {
    return _dio.post(
      ApiConstants.notificationsMarkAllAsRead,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response<dynamic>> markAsRead({
    required String token,
    required int notificationId,
  }) {
    return _dio.post(
      '${ApiConstants.notifications}/$notificationId/read',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
