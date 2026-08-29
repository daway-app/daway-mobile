import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../../core/helpers/json_list_extractor.dart';
import '../../domain/entities/inquiry.dart';
import '../../domain/entities/pharmacy_dashboard_stats.dart';
import '../../domain/repositories/pharmacy_dashboard_repository.dart';
import '../datasources/pharmacy_dashboard_remote_data_source.dart';
import '../models/inquiry_model.dart';
import '../models/pharmacy_dashboard_stats_model.dart';

class PharmacyDashboardRepositoryImpl implements PharmacyDashboardRepository {
  final PharmacyDashboardRemoteDataSource _remoteDataSource;

  const PharmacyDashboardRepositoryImpl(this._remoteDataSource);

  /// `GET /pharmacy/dashboard/stats` covers every count except average
  /// rating. The only endpoint that returns a pre-computed average is the
  /// public, unauthenticated `GET /pharmacies/{id}` — which needs the
  /// pharmacy's numeric id, and nothing the app receives after a pharmacy
  /// login (just the string `pharmacy_id` like `PH-1234`) exposes that. So
  /// the average is derived here instead, from the `stars` on this
  /// pharmacy's own `GET /pharmacy/ratings` (auth-scoped, no id needed).
  ///
  /// The ratings fetch is isolated in its own try/catch rather than sharing
  /// one with the stats fetch: the counts on the stats card are the primary
  /// content of this screen and `/pharmacy/ratings` is a secondary,
  /// best-effort enrichment, so a ratings failure (network error, or one
  /// malformed record with a non-numeric `stars`) degrades to "no rating
  /// data" instead of blanking out counts that were already fetched fine.
  @override
  Future<ApiResult<PharmacyDashboardStats>> getDashboardStats({
    required String token,
  }) async {
    try {
      // All three requests are dispatched here, before any is awaited, so
      // they run concurrently — each helper's own internal `await` means
      // calling it already starts its request without blocking on the
      // stats request first.
      final statsResponseFuture = _remoteDataSource.getStats(token: token);
      final averageRatingFuture = _averageRating(token: token);
      final recentInquiriesFuture = _recentInquiries(token: token);

      final statsResponse = await statsResponseFuture;
      final stats = PharmacyDashboardStatsModel.fromJson(
        statsResponse.data as Map<String, dynamic>,
      );
      final (averageRating, ratingsCount) = await averageRatingFuture;
      final recentInquiries = await recentInquiriesFuture;

      return Success(
        PharmacyDashboardStats(
          totalMedicines: stats.totalMedicines,
          availableCount: stats.availableCount,
          lowStockCount: stats.lowStockCount,
          outOfStockCount: stats.outOfStockCount,
          newInquiriesCount: stats.newInquiriesCount,
          averageRating: averageRating,
          ratingsCount: ratingsCount,
          lowStockItems: stats.lowStockItems,
          recentInquiries: recentInquiries,
        ),
      );
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  /// Same fault-isolation reasoning as [_averageRating]: the home screen's
  /// "أحدث الاستفسارات" preview is a secondary enrichment, so a failure
  /// fetching or parsing it degrades to an empty list instead of taking the
  /// counts down with it. Unlike [_averageRating]'s single `stars` field
  /// though, each inquiry record has several fields that can independently
  /// fail to cast — so parsing is per-record here too: one malformed record
  /// is skipped instead of discarding every other, well-formed one.
  Future<List<Inquiry>> _recentInquiries({required String token}) async {
    try {
      final response = await _remoteDataSource.getRecentInquiries(token: token);
      final inquiriesJson = extractJsonList(
        response.data,
        source: 'GET /pharmacy/inquiries',
      );
      final inquiries = <Inquiry>[];
      for (final json in inquiriesJson) {
        try {
          inquiries.add(
            InquiryModel.fromJson(json as Map<String, dynamic>).toEntity(),
          );
        } catch (_) {
          // Skip just this record.
        }
      }
      return inquiries;
    } catch (_) {
      return const [];
    }
  }

  Future<(double?, int)> _averageRating({required String token}) async {
    try {
      final response = await _remoteDataSource.getRatings(token: token);
      final ratingsJson = extractJsonList(
        response.data,
        source: 'GET /pharmacy/ratings',
      );
      // whereType<num>() (rather than an `as num?` cast) drops a single
      // record with an unexpected `stars` type instead of throwing and
      // losing the average for every other, well-formed record.
      final stars = ratingsJson
          .map((json) => (json as Map<String, dynamic>)['stars'])
          .whereType<num>()
          .map((stars) => stars.toDouble())
          .toList();
      if (stars.isEmpty) return (null, 0);
      return (stars.reduce((a, b) => a + b) / stars.length, stars.length);
    } catch (_) {
      return (null, 0);
    }
  }
}
