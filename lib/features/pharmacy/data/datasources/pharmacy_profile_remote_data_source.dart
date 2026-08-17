import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

class PharmacyProfileRemoteDataSource {
  final Dio _dio;

  const PharmacyProfileRemoteDataSource(this._dio);

  Future<Response<dynamic>> getProfile({required String token}) {
    return _dio.get(
      ApiConstants.pharmacyProfile,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response<dynamic>> updateProfile({
    required String token,
    required Map<String, dynamic> body,
  }) {
    return _dio.post(
      ApiConstants.pharmacyProfile,
      data: body,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
