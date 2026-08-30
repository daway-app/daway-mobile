import '../../../../core/helpers/api_result.dart';
import '../entities/alternatives_overview.dart';
import '../entities/medicine.dart';

abstract class PharmacyAlternativesRepository {
  /// [allMedicines] — this pharmacy's full stock (e.g. from
  /// [GetPharmacyMedicinesUseCase]) — is required because
  /// `GET /pharmacy/medicines/{id}/alternatives` itself returns only a
  /// sparse `{id, trade_name, active_ingredient}` shape per candidate (no
  /// price, quantity, availability, or Arabic name — confirmed against a
  /// live response). Each candidate, and [baseMedicine] itself, is
  /// hydrated/refreshed by matching against [allMedicines] rather than
  /// trusting the sparse fields or a possibly-stale passed-in value.
  Future<ApiResult<AlternativesOverview>> getAlternativesOverview({
    required String token,
    required Medicine baseMedicine,
    required List<Medicine> allMedicines,
  });

  Future<ApiResult<void>> selectAlternative({
    required String token,
    required int baseMedicineId,
    required int alternativeId,
  });

  Future<ApiResult<void>> removeAlternative({
    required String token,
    required int baseMedicineId,
    required int alternativeId,
  });

  /// Every pharmacy_medicine id that already has at least one alternative
  /// linked to it — used to mark a medicine as already handled on the
  /// "البدائل" entry list (which shows every medicine, not just ones
  /// needing an alternative) and to exclude it from that list's
  /// "needs an alternative" count.
  Future<ApiResult<Set<int>>> getBaseMedicineIdsWithAlternatives({
    required String token,
  });
}
