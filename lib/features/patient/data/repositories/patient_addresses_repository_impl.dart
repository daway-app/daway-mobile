import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../../core/helpers/json_list_extractor.dart';
import '../../domain/entities/patient_address.dart';
import '../../domain/repositories/patient_addresses_repository.dart';
import '../datasources/patient_addresses_remote_data_source.dart';
import '../models/patient_address_model.dart';

class PatientAddressesRepositoryImpl implements PatientAddressesRepository {
  final PatientAddressesRemoteDataSource _remoteDataSource;

  const PatientAddressesRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<List<PatientAddress>>> getAddresses({required String token}) async {
    try {
      final response = await _remoteDataSource.getAddresses(token: token);
      final addressesJson = extractJsonList(response.data, source: 'GET /patient/addresses');
      final addresses = addressesJson
          .map((json) => PatientAddressModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
      return Success(addresses);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<PatientAddress>> createAddress({
    required String token,
    required String label,
    required String recipientName,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    bool isDefault = true,
  }) async {
    try {
      final response = await _remoteDataSource.createAddress(
        token: token,
        label: label,
        recipientName: recipientName,
        phone: phone,
        address: address,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );
      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      return Success(PatientAddressModel.fromJson(data).toEntity());
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> deleteAddress({required String token, required int addressId}) async {
    try {
      await _remoteDataSource.deleteAddress(token: token, addressId: addressId);
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<PatientAddress>> updateAddress({
    required String token,
    required int addressId,
    required String label,
    required String recipientName,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    try {
      final response = await _remoteDataSource.updateAddress(
        token: token,
        addressId: addressId,
        label: label,
        recipientName: recipientName,
        phone: phone,
        address: address,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );
      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      return Success(PatientAddressModel.fromJson(data).toEntity());
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
