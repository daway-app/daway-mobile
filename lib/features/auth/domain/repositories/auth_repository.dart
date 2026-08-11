import '../../../../core/helpers/api_result.dart';
import '../entities/patient_auth_result.dart';
import '../entities/pharmacy_auth_result.dart';

abstract class AuthRepository {
  /// Returns the OTP code when the backend echoes it back in the response
  /// (used while the SMS provider isn't wired up yet); null once real SMS
  /// delivery is active and the backend stops including it.
  Future<ApiResult<String?>> sendOtp({required String phone});

  Future<ApiResult<PatientAuthResult>> verifyOtp({
    required String phone,
    required String otp,
  });

  Future<ApiResult<PharmacyAuthResult>> pharmacyLogin({
    required String pharmacyId,
    required String password,
  });

  Future<ApiResult<void>> logout({required String token});
}
