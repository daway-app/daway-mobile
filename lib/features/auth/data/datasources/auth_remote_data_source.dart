import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  const AuthRemoteDataSource(this._dio);

  Future<Response<dynamic>> sendOtp({required String phone}) {
    return _dio.post(ApiConstants.sendOtp, data: {'phone': phone});
  }

  /// Step 1 of sign-up: `POST /register/patient`. Like `/otp/send`, its
  /// response echoes the OTP while SMS delivery isn't wired up.
  Future<Response<dynamic>> registerPatient({
    required String phone,
    required String name,
    required int age,
  }) {
    return _dio.post(
      ApiConstants.registerPatient,
      data: {'phone': phone, 'name': name, 'age': age, 'terms_accepted': true},
    );
  }

  Future<Response<dynamic>> verifyOtp({
    required String phone,
    required String otp,
    String? name,
    int? age,
    bool? termsAccepted,
    double? latitude,
    double? longitude,
    bool? notificationsEnabled,
  }) {
    return _dio.post(
      ApiConstants.otpVerify,
      data: {
        'phone': phone,
        'otp': otp,
        'name': ?name,
        'age': ?age,
        'terms_accepted': ?termsAccepted,
        'latitude': ?latitude,
        'longitude': ?longitude,
        'notifications_enabled': ?notificationsEnabled,
      },
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

  Future<Response<dynamic>> registerPharmacy({
    required String pharmacyName,
    required String phone,
    required String region,
    required String password,
  }) {
    return _dio.post(
      ApiConstants.registerPharmacy,
      data: {
        'pharmacy_name': pharmacyName,
        'phone': phone,
        'region': region,
        'password': password,
      },
    );
  }

  Future<Response<dynamic>> logout({required String token}) {
    return _dio.post(
      ApiConstants.logout,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
