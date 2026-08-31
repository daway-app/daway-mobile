import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../../core/helpers/json_list_extractor.dart';
import '../../../../core/helpers/sort_by_date.dart';
import '../../domain/entities/rating.dart';
import '../../domain/repositories/pharmacy_ratings_repository.dart';
import '../datasources/pharmacy_ratings_remote_data_source.dart';
import '../models/rating_model.dart';

class PharmacyRatingsRepositoryImpl implements PharmacyRatingsRepository {
  final PharmacyRatingsRemoteDataSource _remoteDataSource;

  const PharmacyRatingsRepositoryImpl(this._remoteDataSource);

  /// `GET /pharmacy/ratings` returns only the raw list of reviews (plus a
  /// `pagination.total`) — no server-computed average or per-star counts
  /// like `PharmacyInquiriesRepository` gets from its `counts` object — so
  /// both are derived here from the fetched page. One malformed rating
  /// record is skipped rather than failing the whole list, same reasoning
  /// as PharmacyInquiriesRepositoryImpl.getInquiries.
  @override
  Future<ApiResult<RatingsOverview>> getRatings({required String token}) async {
    try {
      final response = await _remoteDataSource.getRatings(token: token);
      final body = response.data as Map<String, dynamic>;
      final ratingsJson = extractJsonList(
        body,
        source: 'GET /pharmacy/ratings',
      );

      final ratings = <Rating>[];
      for (final json in ratingsJson) {
        try {
          ratings.add(
            RatingModel.fromJson(json as Map<String, dynamic>).toEntity(),
          );
        } catch (_) {
          // Skip just this record.
        }
      }
      sortByDateDescending(ratings, (r) => r.createdAt);

      final starCounts = {for (final s in [5, 4, 3, 2, 1]) s: 0};
      var starsSum = 0;
      for (final rating in ratings) {
        starsSum += rating.stars;
        if (starCounts.containsKey(rating.stars)) {
          starCounts[rating.stars] = starCounts[rating.stars]! + 1;
        }
      }
      final averageRating = ratings.isEmpty ? 0.0 : starsSum / ratings.length;

      // Isolated in its own try/catch, same reasoning as
      // PharmacyDashboardRepositoryImpl's _averageRating/_recentInquiries:
      // pagination.total is a best-effort enrichment on top of the ratings
      // list that's already been fully parsed above, so a malformed shape
      // here should fall back to the parsed count instead of discarding
      // that list via the outer catch.
      int totalCount;
      try {
        final pagination = body['pagination'] as Map<String, dynamic>?;
        totalCount = (pagination?['total'] as num?)?.toInt() ?? ratings.length;
      } catch (_) {
        totalCount = ratings.length;
      }

      return Success(
        RatingsOverview(
          ratings: ratings,
          totalCount: totalCount,
          averageRating: averageRating,
          starCounts: starCounts,
        ),
      );
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
