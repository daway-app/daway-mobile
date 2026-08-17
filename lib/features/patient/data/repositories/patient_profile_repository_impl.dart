import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/patient_profile.dart';
import '../../domain/repositories/patient_profile_repository.dart';
import '../datasources/patient_profile_remote_data_source.dart';

class PatientProfileRepositoryImpl implements PatientProfileRepository {
  final PatientProfileRemoteDataSource _remoteDataSource;

  const PatientProfileRepositoryImpl(this._remoteDataSource);

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
          'latitude': profile.latitude,
          'longitude': profile.longitude,
          'address': profile.address,
        },
      );
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
