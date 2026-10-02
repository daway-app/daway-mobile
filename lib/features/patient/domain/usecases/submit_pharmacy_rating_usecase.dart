import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../repositories/patient_ratings_repository.dart';

class SubmitPharmacyRatingUseCase {
  final PatientRatingsRepository _repository;
  final SessionRepository _sessionRepository;

  const SubmitPharmacyRatingUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<void>> call({
    required int pharmacyId,
    required int stars,
    String? comment,
  }) async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.submitPharmacyRating(
      token: session.token,
      pharmacyId: pharmacyId,
      stars: stars,
      comment: comment,
    );
  }
}
