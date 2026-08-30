import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../repositories/pharmacy_alternatives_repository.dart';

class GetMedicineIdsWithAlternativeUseCase {
  final PharmacyAlternativesRepository _repository;
  final SessionRepository _sessionRepository;

  const GetMedicineIdsWithAlternativeUseCase(
    this._repository,
    this._sessionRepository,
  );

  Future<ApiResult<Set<int>>> call() async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.getBaseMedicineIdsWithAlternatives(token: session.token);
  }
}
