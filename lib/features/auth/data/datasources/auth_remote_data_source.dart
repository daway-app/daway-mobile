import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  const AuthRemoteDataSource(this._dio);

  Future<Response<dynamic>> sendOtp({required String phone}) {
    return _dio.post(ApiConstants.sendOtp, data: {'phone': phone});
  }

  Future<Response<dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) {
    return _dio.post(
      ApiConstants.patientLogin,
      data: {'phone': phone, 'otp': otp},
    );
  }

  Future<Response<dynamic>> pharmacyLogin({
    required String pharmacyId,
    required String password,
  }) {
    return _dio.post(
      ApiConstants.pharmacyLogin,
      data: {'pharmacy_id': pharmacyId, 'password': password},
    );
  }

  Future<Response<dynamic>> logout({required String token}) {
    return _dio.post(
      ApiConstants.logout,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
