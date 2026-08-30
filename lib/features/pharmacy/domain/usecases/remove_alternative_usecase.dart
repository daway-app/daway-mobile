import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../repositories/pharmacy_alternatives_repository.dart';

class RemoveAlternativeUseCase {
  final PharmacyAlternativesRepository _repository;
  final SessionRepository _sessionRepository;

  const RemoveAlternativeUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<void>> call({
    required int baseMedicineId,
    required int alternativeId,
  }) async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.removeAlternative(
      token: session.token,
      baseMedicineId: baseMedicineId,
      alternativeId: alternativeId,
    );
  }
}
