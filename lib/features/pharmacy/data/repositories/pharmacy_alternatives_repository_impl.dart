import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../../core/helpers/json_list_extractor.dart';
import '../../domain/entities/alternatives_overview.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/repositories/pharmacy_alternatives_repository.dart';
import '../datasources/pharmacy_alternatives_remote_data_source.dart';

class PharmacyAlternativesRepositoryImpl
    implements PharmacyAlternativesRepository {
  final PharmacyAlternativesRemoteDataSource _remoteDataSource;

  const PharmacyAlternativesRepositoryImpl(this._remoteDataSource);

  /// `GET /pharmacy/medicines/{id}/alternatives` (same-active-ingredient
  /// candidates from this pharmacy's own stock) is the primary content of
  /// this screen, so a failure there fails the whole call. Confirmed
  /// against a live response, it returns only a sparse
  /// `{"id": ..., "trade_name": ..., "active_ingredient": ...}` per
  /// candidate, where `id` is the candidate's catalog medicine id — no
  /// price, quantity, availability, or Arabic name — and NOT the same shape
  /// as `GET /pharmacy/medicines` despite an earlier assumption to that
  /// effect. Each candidate is hydrated by matching that catalog id against
  /// [allMedicines] (passed in already-fetched by
  /// [GetAlternativesOverviewUseCase]) and used as-is — its `Medicine.id`
  /// stays that medicine's own `pharmacy_medicine` stock-row id, same as
  /// every other [Medicine] in the app; callers needing the catalog id to
  /// select/remove this candidate as an alternative (see [_allLinks]) read
  /// `Medicine.medicineId` instead, never `Medicine.id`.
  ///
  /// [baseMedicine] is likewise re-hydrated from [allMedicines] (falling
  /// back to the passed-in value if it's gone missing between fetches) so
  /// its displayed quantity/status can't go stale relative to the freshly
  /// fetched stock the candidates are hydrated from.
  ///
  /// Which candidate is already linked is a secondary cross-reference
  /// against the separate, pharmacy-wide `GET /pharmacy/alternatives` list —
  /// isolated in its own try/catch so a failure there just means nothing
  /// shows as pre-selected, same fault-isolation reasoning used for
  /// ratings/recent-inquiries on the dashboard.
  @override
  Future<ApiResult<AlternativesOverview>> getAlternativesOverview({
    required String token,
    required Medicine baseMedicine,
    required List<Medicine> allMedicines,
  }) async {
    try {
      final candidatesFuture = _remoteDataSource.getCandidates(
        token: token,
        pharmacyMedicineId: baseMedicine.id,
      );
      final linksFuture = _allLinks(token: token);

      final candidatesResponse = await candidatesFuture;
      // Awaited here, right after the other network call and before any
      // parsing below that can throw, so a malformed candidates payload can
      // never leave this already-in-flight request orphaned.
      final links = await linksFuture;
      final candidatesJson = extractJsonList(
        candidatesResponse.data,
        source: 'GET /pharmacy/medicines/{id}/alternatives',
      );
      final candidateMedicineIds = candidatesJson
          .map(
            (json) => ((json as Map<String, dynamic>)['id'] as num?)?.toInt(),
          )
          .whereType<int>()
          .toSet();
      final medicinesByMedicineId = {
        for (final medicine in allMedicines) medicine.medicineId: medicine,
      };
      final medicinesById = {
        for (final medicine in allMedicines) medicine.id: medicine,
      };
      final candidates = candidateMedicineIds
          .map((catalogId) => medicinesByMedicineId[catalogId])
          .whereType<Medicine>()
          .toList();

      return Success(
        AlternativesOverview(
          baseMedicine: medicinesById[baseMedicine.id] ?? baseMedicine,
          candidates: candidates,
          selectedAlternativeIds: links[baseMedicine.id] ?? const {},
        ),
      );
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<Set<int>>> getBaseMedicineIdsWithAlternatives({
    required String token,
  }) async {
    final links = await _allLinks(token: token);
    return Success(links.keys.toSet());
  }

  /// Confirmed against a live response: `GET /pharmacy/alternatives` is
  /// grouped by base medicine, not a flat list of `{base_medicine_id,
  /// alternative_id}` pairs —
  /// `[{"id": 14, ..., "alternatives": [{"id": 16, ...}, {"id": 15, ...}]}]`
  /// — where the top-level `id` is the base medicine's own `pharmacy_medicine`
  /// id (the same value sent as `base_medicine_id` to create the link), but
  /// each nested `alternatives[].id` is that alternative's **catalog**
  /// medicine id, not its `pharmacy_medicine` id — confirmed by cross
  /// -checking against `GET /pharmacy/medicines/{id}/alternatives`, which
  /// returns candidates keyed the same way, and is what `selectAlternative`
  /// actually sends as `alternative_id`. Parsed once here into base id →
  /// linked (catalog) ids, reused by both [getAlternativesOverview] (looks
  /// up one base medicine) and [getBaseMedicineIdsWithAlternatives]
  /// (collects every base medicine that has at least one link) so they
  /// can't drift out of sync on how this shape is read. Fault-tolerant like
  /// the rest of this repository's secondary-data fetches: any failure —
  /// network, unexpected shape, a malformed entry — degrades to "no links
  /// known" rather than failing whichever screen asked.
  Future<Map<int, Set<int>>> _allLinks({required String token}) async {
    try {
      final response = await _remoteDataSource.getLinks(token: token);
      final entriesJson = extractJsonList(
        response.data,
        source: 'GET /pharmacy/alternatives',
      );
      final result = <int, Set<int>>{};
      for (final json in entriesJson) {
        try {
          final map = json as Map<String, dynamic>;
          final baseId = (map['id'] as num).toInt();
          final alternativesJson =
              map['alternatives'] as List<dynamic>? ?? const [];
          final altIds = alternativesJson
              .map(
                (alt) => ((alt as Map<String, dynamic>)['id'] as num?)?.toInt(),
              )
              .whereType<int>()
              .toSet();
          if (altIds.isNotEmpty) {
            // Merge rather than overwrite on a repeated base id — a
            // duplicate entry in the response should never make a
            // previously-seen link disappear.
            result.update(
              baseId,
              (existing) => existing..addAll(altIds),
              ifAbsent: () => altIds,
            );
          }
        } catch (_) {
          // Skip just this entry.
        }
      }
      return result;
    } catch (_) {
      return const {};
    }
  }

  @override
  Future<ApiResult<void>> selectAlternative({
    required String token,
    required int baseMedicineId,
    required int alternativeId,
  }) async {
    try {
      await _remoteDataSource.create(
        token: token,
        baseMedicineId: baseMedicineId,
        alternativeId: alternativeId,
      );
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> removeAlternative({
    required String token,
    required int baseMedicineId,
    required int alternativeId,
  }) async {
    try {
      await _remoteDataSource.delete(
        token: token,
        baseMedicineId: baseMedicineId,
        alternativeId: alternativeId,
      );
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
