import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/patient_profile.dart';
import '../../domain/repositories/patient_profile_repository.dart';
import '../datasources/patient_profile_remote_data_source.dart';
import '../models/patient_profile_model.dart';

class PatientProfileRepositoryImpl implements PatientProfileRepository {
  final PatientProfileRemoteDataSource _remoteDataSource;

  const PatientProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<PatientProfile>> getProfile({required String token}) async {
    try {
      final response = await _remoteDataSource.getProfile(token: token);
      final model = PatientProfileModel.fromJson(response.data as Map<String, dynamic>);
      return Success(model.toEntity());
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> updateProfile({
    required String token,
    required PatientProfile profile,
  }) async {
    try {
      await _remoteDataSource.updateProfile(
        token: token,
        body: {
          'name': profile.name,
          'phone': profile.phone,
          if (profile.avatarUrl != null) 'avatar_url': profile.avatarUrl,
          if (profile.birthDate != null) 'birth_date': profile.birthDate,
          if (profile.latitude != null) 'latitude': profile.latitude,
          if (profile.longitude != null) 'longitude': profile.longitude,
          if (profile.address != null) 'address': profile.address,
        },
      );
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
