import '../../domain/entities/rating.dart';

sealed class PharmacyRatingsState {
  const PharmacyRatingsState();
}

class PharmacyRatingsLoading extends PharmacyRatingsState {
  const PharmacyRatingsLoading();
}

class PharmacyRatingsLoadFailure extends PharmacyRatingsState {
  final String message;

  const PharmacyRatingsLoadFailure(this.message);
}

class PharmacyRatingsLoaded extends PharmacyRatingsState {
  final List<Rating> ratings;
  final int totalCount;
  final double averageRating;
  final Map<int, int> starCounts;

  const PharmacyRatingsLoaded({
    required this.ratings,
    required this.totalCount,
    required this.averageRating,
    required this.starCounts,
  });
}
