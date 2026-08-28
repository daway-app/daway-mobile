import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

class PharmacyMedicineRemoteDataSource {
  final Dio _dio;

  const PharmacyMedicineRemoteDataSource(this._dio);

  Future<Response<dynamic>> getMedicines({required String token}) {
    return _dio.get(
      ApiConstants.pharmacyMedicines,
      queryParameters: {'per_page': 100},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response<dynamic>> searchCatalog({required String token, required String query}) {
    return _dio.get(
      ApiConstants.pharmacyMedicinesSearch,
      queryParameters: {'q': query},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response<dynamic>> addMedicine({
    required String token,
    required Map<String, dynamic> body,
  }) {
    return _dio.post(
      ApiConstants.pharmacyMedicines,
      data: body,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response<dynamic>> addMedicineByName({
    required String token,
    required Map<String, dynamic> body,
  }) {
    return _dio.post(
      ApiConstants.pharmacyMedicinesByName,
      data: body,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response<dynamic>> deleteMedicine({
    required String token,
    required int pharmacyMedicineId,
  }) {
    return _dio.delete(
      '${ApiConstants.pharmacyMedicines}/$pharmacyMedicineId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  /// `PUT /pharmacy/medicines/{id}` — confirmed against the team's Postman
  /// collection ("Update Medicine"), which sends `medicine_id` in the body
  /// alongside the stock fields even though it's already implied by the
  /// path; the backend apparently validates it as required.
  Future<Response<dynamic>> updateMedicine({
    required String token,
    required int pharmacyMedicineId,
    required Map<String, dynamic> body,
  }) {
    return _dio.put(
      '${ApiConstants.pharmacyMedicines}/$pharmacyMedicineId',
      data: body,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
