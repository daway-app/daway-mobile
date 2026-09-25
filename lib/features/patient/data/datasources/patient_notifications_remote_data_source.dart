import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

class PatientNotificationsRemoteDataSource {
  final Dio _dio;

  const PatientNotificationsRemoteDataSource(this._dio);

  /// One page (1-based) of the list — the endpoint has a fixed page size and
  /// ignores `per_page`, so the repository reads every page.
  Future<Response<dynamic>> getNotifications({required String token, int page = 1}) {
    return _dio.get(
      ApiConstants.notifications,
      queryParameters: {'page': page},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
