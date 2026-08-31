import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../entities/rating.dart';
import '../repositories/pharmacy_ratings_repository.dart';

class GetPharmacyRatingsUseCase {
  final PharmacyRatingsRepository _repository;
  final SessionRepository _sessionRepository;

  const GetPharmacyRatingsUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<RatingsOverview>> call() async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.getRatings(token: session.token);
  }
}
