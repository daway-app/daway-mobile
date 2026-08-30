import '../../../../core/helpers/api_result.dart';
import '../entities/medicine.dart';
import 'get_medicine_ids_with_alternative_usecase.dart';
import 'get_pharmacy_medicines_usecase.dart';

/// Every one of the pharmacy's medicines, alongside which ones already have
/// an alternative linked and which ones still need one — combines two
/// independent fetches (all medicines, and which medicine ids already have
/// an alternative) so the "البدائل" screen can show the full list while
/// still knowing, per medicine, whether it still needs attention.
class GetMedicinesWithAlternativeStatusUseCase {
  final GetPharmacyMedicinesUseCase _getPharmacyMedicinesUseCase;
  final GetMedicineIdsWithAlternativeUseCase
  _getMedicineIdsWithAlternativeUseCase;

  const GetMedicinesWithAlternativeStatusUseCase(
    this._getPharmacyMedicinesUseCase,
    this._getMedicineIdsWithAlternativeUseCase,
  );

  Future<
    ApiResult<
      ({
        List<Medicine> medicines,
        Set<int> alreadyHandledIds,
        Set<int> needingAlternativeIds,
      })
    >
  >
  call() async {
    final medicinesFuture = _getPharmacyMedicinesUseCase();
    final withAlternativeFuture = _getMedicineIdsWithAlternativeUseCase();

    final medicinesResult = await medicinesFuture;
    final withAlternativeResult = await withAlternativeFuture;

    return switch (medicinesResult) {
      ApiError(:final failure) => ApiError(failure),
      Success(:final data) => Success(_combine(data, withAlternativeResult)),
    };
  }

  ({
    List<Medicine> medicines,
    Set<int> alreadyHandledIds,
    Set<int> needingAlternativeIds,
  })
  _combine(
    List<Medicine> medicines,
    ApiResult<Set<int>> withAlternativeResult,
  ) {
    // A failure fetching "which medicines already have an alternative"
    // degrades to an empty set (nothing shown as already handled) rather
    // than failing this whole screen — that data is a refinement on top of
    // the primary medicines list, not primary content itself.
    final alreadyHandledIds = switch (withAlternativeResult) {
      Success(:final data) => data,
      ApiError() => const <int>{},
    };
    final needingAlternativeIds = medicines
        .where(
          (m) =>
              (m.status == MedicineStatus.low ||
                  m.status == MedicineStatus.outOfStock) &&
              !alreadyHandledIds.contains(m.id),
        )
        .map((m) => m.id)
        .toSet();
    return (
      medicines: medicines,
      alreadyHandledIds: alreadyHandledIds,
      needingAlternativeIds: needingAlternativeIds,
    );
  }
}
