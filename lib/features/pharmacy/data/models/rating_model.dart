import '../../domain/entities/rating.dart';

/// Parses one entry from `GET /pharmacy/ratings`. Only `stars` is confirmed
/// against a live response (see PharmacyDashboardRepositoryImpl's average
/// rating calculation) — no pharmacy on the demo backend has an actual
/// review yet to confirm `comment`/`created_at`/the reviewer-name key
/// against, so this tries both `patient` and `user` for the nested
/// reviewer object (the latter is what `GET /pharmacy/inquiries` uses for
/// the patient who filed an inquiry) and defaults defensively otherwise.
class RatingModel {
  final int id;
  final int stars;
  final String? comment;
  final DateTime createdAt;
  final String patientName;

  const RatingModel({
    required this.id,
    required this.stars,
    this.comment,
    required this.createdAt,
    required this.patientName,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    final reviewer =
        json['patient'] as Map<String, dynamic>? ??
        json['user'] as Map<String, dynamic>?;
    return RatingModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      // Required, unlike id/comment/name below: a rating with no valid star
      // count isn't a real review, and letting it default would silently
      // pollute the average while staying invisible in the 1-5 histogram.
      stars: (json['stars'] as num).toInt(),
      comment: json['comment'] as String?,
      // Required too: this repository sorts by createdAt to show the newest
      // reviews first, so a fallback like DateTime.now() would wrongly sort
      // a corrupted record to the top instead of just being skipped.
      createdAt: DateTime.parse(json['created_at'] as String),
      patientName: reviewer?['name'] as String? ?? 'مستخدم',
    );
  }

  Rating toEntity() => Rating(
    id: id,
    stars: stars,
    comment: comment,
    createdAt: createdAt,
    patientName: patientName,
  );
}
