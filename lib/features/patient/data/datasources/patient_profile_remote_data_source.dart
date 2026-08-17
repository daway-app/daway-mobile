import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

class PatientProfileRemoteDataSource {
  final Dio _dio;

  const PatientProfileRemoteDataSource(this._dio);

  Future<Response<dynamic>> updateProfile({
    required String token,
    required Map<String, dynamic> body,
  }) {
    return _dio.post(
      ApiConstants.patientProfile,
      data: body,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
