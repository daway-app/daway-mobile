import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../repositories/pharmacy_alternatives_repository.dart';

/// Picking a new alternative for a medicine is exclusive in this app's UI —
/// only one candidate ever shows as "تم اختياره" — even though the backend
/// itself allows a base medicine to have several linked alternatives at
/// once (confirmed against a live response). So this unlinks every id in
/// [previousAlternativeIds] (skipping [newAlternativeId] if it's somehow
/// already among them) before linking the new one, keeping that
/// single-selection rule enforced in the domain layer rather than the
/// screen deciding when to fire extra requests.
class SelectAlternativeUseCase {
  final PharmacyAlternativesRepository _repository;
  final SessionRepository _sessionRepository;

  const SelectAlternativeUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<void>> call({
    required int baseMedicineId,
    required int newAlternativeId,
    required Set<int> previousAlternativeIds,
  }) async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }

    final idsToRemove = previousAlternativeIds.where(
      (id) => id != newAlternativeId,
    );
    final removeResults = await Future.wait(
      idsToRemove.map(
        (previousId) => _repository.removeAlternative(
          token: session.token,
          baseMedicineId: baseMedicineId,
          alternativeId: previousId,
        ),
      ),
    );
    for (final removeResult in removeResults) {
      if (removeResult is ApiError) return removeResult;
    }

    return _repository.selectAlternative(
      token: session.token,
      baseMedicineId: baseMedicineId,
      alternativeId: newAlternativeId,
    );
  }
}
