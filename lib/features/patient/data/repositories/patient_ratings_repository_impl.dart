import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../domain/repositories/patient_ratings_repository.dart';
import '../datasources/patient_ratings_remote_data_source.dart';

class PatientRatingsRepositoryImpl implements PatientRatingsRepository {
  final PatientRatingsRemoteDataSource _remoteDataSource;

  const PatientRatingsRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<void>> submitPharmacyRating({
    required String token,
    required int pharmacyId,
    required int stars,
    String? comment,
  }) async {
    try {
      await _remoteDataSource.submitRating(
        token: token,
        pharmacyId: pharmacyId,
        stars: stars,
        comment: comment,
      );
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
