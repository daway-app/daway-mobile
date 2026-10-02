import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

class HealthProfileRemoteDataSource {
  final Dio _dio;

  const HealthProfileRemoteDataSource(this._dio);

  Future<Response<dynamic>> getHealthProfile({required String token}) {
    return _dio.get(
      ApiConstants.patientHealthProfile,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response<dynamic>> updateHealthProfile({
    required String token,
    required List<String> allergies,
    required List<String> chronicDiseases,
    required String? bloodType,
    required String notes,
  }) {
    return _dio.put(
      ApiConstants.patientHealthProfile,
      data: {
        'allergies': allergies,
        'chronic_diseases': chronicDiseases,
        'blood_type': bloodType,
        'notes': notes,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
