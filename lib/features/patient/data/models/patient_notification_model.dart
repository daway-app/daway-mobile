import '../../../../core/helpers/server_timestamp.dart';
import '../../domain/entities/patient_notification.dart';

/// Parses one entry from `GET /notifications` — the same shape the pharmacy
/// side confirmed live (`id`, `type`, `message`, `is_read`, `created_at`);
/// only the `type` values differ per role.
class PatientNotificationModel {
  final int id;
  final PatientNotificationType type;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const PatientNotificationModel({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory PatientNotificationModel.fromJson(Map<String, dynamic> json) {
    return PatientNotificationModel(
      id: (json['id'] as num).toInt(),
      // A type check rather than `as String?`: a `type` of the wrong JSON
      // type should degrade to PatientNotificationType.other, not skip the
      // whole record over a display-only field.
      type: patientNotificationTypeFrom(json['type'] is String ? json['type'] as String : null),
      message: json['message'] as String? ?? '',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      // Required: the list is sorted newest-first by this, so a fallback like
      // DateTime.now() would wrongly float a corrupted record to the top.
      // The server sends UTC; the item's relative time and date compare it
      // against the device's clock, so it is converted to local time here.
      createdAt: parseServerTimestamp(json['created_at'] as String),
    );
  }

  PatientNotification toEntity() => PatientNotification(
        id: id,
        type: type,
        message: message,
        isRead: isRead,
        createdAt: createdAt,
      );
}
