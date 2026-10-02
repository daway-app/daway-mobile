import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

class PatientInquiriesRemoteDataSource {
  final Dio _dio;

  const PatientInquiriesRemoteDataSource(this._dio);

  Future<Response<dynamic>> getInquiries({required String token, int page = 1}) {
    return _dio.get(
      ApiConstants.patientInquiries,
      queryParameters: {'page': page},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response<dynamic>> createInquiry({
    required String token,
    required int pharmacyId,
    int? medicineId,
    required String message,
  }) {
    return _dio.post(
      ApiConstants.patientInquiries,
      data: {'pharmacy_id': pharmacyId, 'medicine_id': ?medicineId, 'message': message},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
