import '../../domain/entities/notification.dart';

/// Parses one entry from `GET /notifications` — confirmed against a live
/// response: `id`, `type` (`low_stock`/`out_of_stock`/`new_inquiry`),
/// `message` (a full, ready-to-display sentence), `is_read`, `created_at`.
class NotificationModel {
  final int id;
  final NotificationType type;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      // Required, not defaulted: this id targets the mark-as-read mutation,
      // so a malformed record silently becoming id 0 could mark the wrong
      // notification read instead of just being skipped.
      id: (json['id'] as num).toInt(),
      // A type check rather than `as String?`: a `type` of the wrong JSON
      // type (e.g. a numeric code) should degrade to NotificationType.other
      // like an unrecognized string does, not skip the whole record over a
      // display-only field.
      type: notificationTypeFrom(
        json['type'] is String ? json['type'] as String : null,
      ),
      message: json['message'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      // Required too, same reasoning as RatingModel: this repository sorts
      // by createdAt to show the newest notifications first, so a fallback
      // like DateTime.now() would wrongly sort a corrupted record to the top
      // instead of just being skipped.
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  AppNotification toEntity() => AppNotification(
    id: id,
    type: type,
    message: message,
    isRead: isRead,
    createdAt: createdAt,
  );
}
