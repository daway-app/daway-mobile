import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

class PatientAddressesRemoteDataSource {
  final Dio _dio;

  const PatientAddressesRemoteDataSource(this._dio);

  Future<Response<dynamic>> getAddresses({required String token}) {
    return _dio.get(
      ApiConstants.patientAddresses,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response<dynamic>> createAddress({
    required String token,
    required String label,
    required String recipientName,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) {
    return _dio.post(
      ApiConstants.patientAddresses,
      data: {
        'label': label,
        'recipient_name': recipientName,
        'phone': phone,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'is_default': isDefault,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response<dynamic>> deleteAddress({required String token, required int addressId}) {
    return _dio.delete(
      '${ApiConstants.patientAddresses}/$addressId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response<dynamic>> updateAddress({
    required String token,
    required int addressId,
    required String label,
    required String recipientName,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) {
    return _dio.put(
      '${ApiConstants.patientAddresses}/$addressId',
      data: {
        'label': label,
        'recipient_name': recipientName,
        'phone': phone,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'is_default': isDefault,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
