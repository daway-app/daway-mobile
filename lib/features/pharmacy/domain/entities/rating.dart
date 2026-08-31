/// One patient's rating of the pharmacy — the `comment` is optional on
/// `POST /ratings`, so it may be null here too.
class Rating {
  final int id;
  final int stars;
  final String? comment;
  final DateTime createdAt;
  final String patientName;

  const Rating({
    required this.id,
    required this.stars,
    this.comment,
    required this.createdAt,
    required this.patientName,
  });
}

/// The full response shape of `GET /pharmacy/ratings`: the page of reviews
/// plus aggregates derived from that same page (see
/// PharmacyRatingsRepositoryImpl for why they're derived client-side rather
/// than read from the backend). [totalCount] is the backend's own
/// `pagination.total` and stays accurate even when [ratings] is a partial
/// page, but [averageRating] and [starCounts] only reflect the fetched page.
class RatingsOverview {
  final List<Rating> ratings;
  final int totalCount;
  final double averageRating;

  /// Count of reviews for each star value 1–5 — always has all five keys.
  final Map<int, int> starCounts;

  const RatingsOverview({
    required this.ratings,
    required this.totalCount,
    required this.averageRating,
    required this.starCounts,
  });
}
