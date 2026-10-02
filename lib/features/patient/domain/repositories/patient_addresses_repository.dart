import '../../../../core/helpers/api_result.dart';
import '../entities/patient_address.dart';

abstract class PatientAddressesRepository {
  Future<ApiResult<List<PatientAddress>>> getAddresses({required String token});

  Future<ApiResult<PatientAddress>> createAddress({
    required String token,
    required String label,
    required String recipientName,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    bool isDefault = true,
  });

  /// `DELETE /patient/addresses/{id}`.
  Future<ApiResult<void>> deleteAddress({required String token, required int addressId});

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
  });
}
