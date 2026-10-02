import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

class AvailabilityAlertsRemoteDataSource {
  final Dio _dio;

  const AvailabilityAlertsRemoteDataSource(this._dio);

  /// 201 when new, 200 when the patient is already subscribed; both are
  /// success. `pharmacy_id` is optional (null = any pharmacy).
  Future<Response<dynamic>> create({required String token, required int medicineId}) {
    return _dio.post(
      ApiConstants.patientAvailabilityAlerts,
      data: {'medicine_id': medicineId},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
