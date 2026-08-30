import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../entities/alternatives_overview.dart';
import '../entities/medicine.dart';
import '../repositories/pharmacy_alternatives_repository.dart';
import 'get_pharmacy_medicines_usecase.dart';

class GetAlternativesOverviewUseCase {
  final PharmacyAlternativesRepository _repository;
  final GetPharmacyMedicinesUseCase _getPharmacyMedicinesUseCase;
  final SessionRepository _sessionRepository;

  const GetAlternativesOverviewUseCase(
    this._repository,
    this._getPharmacyMedicinesUseCase,
    this._sessionRepository,
  );

  Future<ApiResult<AlternativesOverview>> call(Medicine baseMedicine) async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }

    // The candidates endpoint alone doesn't carry enough to render a card
    // (see PharmacyAlternativesRepositoryImpl) — the full stock list is
    // fetched here so the repository can hydrate each candidate with its
    // real price/quantity/name instead of the sparse fields it returns.
    final medicinesResult = await _getPharmacyMedicinesUseCase();
    return switch (medicinesResult) {
      ApiError(:final failure) => ApiError(failure),
      Success(:final data) => _repository.getAlternativesOverview(
        token: session.token,
        baseMedicine: baseMedicine,
        allMedicines: data,
      ),
    };
  }
}
