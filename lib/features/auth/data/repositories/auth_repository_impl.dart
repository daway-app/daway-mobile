import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/patient_auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/patient_auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<String?>> sendOtp({required String phone}) async {
    try {
      final response = await _remoteDataSource.sendOtp(phone: phone);
      final data = response.data as Map<String, dynamic>;
      return Success(data['otp'] as String?);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<PatientAuthResult>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _remoteDataSource.verifyOtp(
        phone: phone,
        otp: otp,
      );
      final model = PatientAuthResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Success(
        PatientAuthResult(token: model.token, isNewAccount: model.isNewAccount),
      );
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
