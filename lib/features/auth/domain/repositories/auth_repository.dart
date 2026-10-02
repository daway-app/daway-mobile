import '../../../../core/helpers/api_result.dart';
import '../entities/patient_auth_result.dart';
import '../entities/pharmacy_auth_result.dart';

abstract class AuthRepository {
  /// Returns the OTP code when the backend echoes it back in the response
  /// (used while the SMS provider isn't wired up yet); null once real SMS
  /// delivery is active and the backend stops including it.
  ///
  /// When [name] and [birthDate] are given this is the sign-up request
  /// (`POST /register/patient`, which takes an age derived from the birth
  /// date); otherwise it is the plain login OTP request.
  Future<ApiResult<String?>> sendOtp({
    required String phone,
    String? name,
    String? birthDate,
  });

  Future<ApiResult<PatientAuthResult>> verifyOtp({
    required String phone,
    required String otp,
    String? name,
    String? birthDate,
    double? latitude,
    double? longitude,
    bool? notificationsEnabled,
  });

  Future<ApiResult<PharmacyAuthResult>> pharmacyLogin({
    required String pharmacyId,
    required String password,
  });

  /// Creates a pharmacy account pending admin approval — the backend never
  /// returns login credentials here; once approved, the pharmacy_id and
  /// chosen password are sent to them out-of-band.
  Future<ApiResult<void>> registerPharmacy({
    required String pharmacyName,
    required String phone,
    required String region,
    required String password,
  });

  Future<ApiResult<void>> logout({required String token});
}
