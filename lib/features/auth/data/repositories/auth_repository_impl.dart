import '../../../../core/erroring/error_handler.dart';
import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/age_calculator.dart';
import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/patient_auth_result.dart';
import '../../domain/entities/pharmacy_auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/patient_auth_response_model.dart';
import '../models/pharmacy_auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<String?>> sendOtp({
    required String phone,
    String? name,
    String? birthDate,
  }) async {
    try {
      final age = birthDate == null ? null : ageFromBirthDate(birthDate);
      final response = (name != null && age != null)
          ? await _remoteDataSource.registerPatient(phone: phone, name: name, age: age)
          : await _remoteDataSource.sendOtp(phone: phone);
      final data = response.data as Map<String, dynamic>;
      // Plain login for a phone with no account: the OTP would only lead to
      // a "no account" error after the code is typed, so stop here instead.
      if (name == null && data['is_registered'] == false) {
        return const ApiError(
          ApiFailure(
            message: 'لا يوجد حساب بهذا الرقم، يرجى إنشاء حساب جديد',
            registrationRequired: true,
          ),
        );
      }
      return Success(data['otp'] as String?);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<PatientAuthResult>> verifyOtp({
    required String phone,
    required String otp,
    String? name,
    String? birthDate,
    double? latitude,
    double? longitude,
    bool? notificationsEnabled,
  }) async {
    try {
      final response = await _remoteDataSource.verifyOtp(
        phone: phone,
        otp: otp,
        name: name,
        age: birthDate == null ? null : ageFromBirthDate(birthDate),
        termsAccepted: name != null ? true : null,
        latitude: latitude,
        longitude: longitude,
        notificationsEnabled: notificationsEnabled,
      );
      final model = PatientAuthResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Success(
        PatientAuthResult(
          token: model.token,
          isNewAccount: model.isNewAccount,
          userId: model.userId,
        ),
      );
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<PharmacyAuthResult>> pharmacyLogin({
    required String pharmacyId,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.pharmacyLogin(
        pharmacyId: pharmacyId,
        password: password,
      );
      final model = PharmacyAuthResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Success(PharmacyAuthResult(token: model.token, userId: model.userId));
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> registerPharmacy({
    required String pharmacyName,
    required String phone,
    required String region,
    required String password,
  }) async {
    try {
      await _remoteDataSource.registerPharmacy(
        pharmacyName: pharmacyName,
        phone: phone,
        region: region,
        password: password,
      );
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> logout({required String token}) async {
    try {
      await _remoteDataSource.logout(token: token);
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
