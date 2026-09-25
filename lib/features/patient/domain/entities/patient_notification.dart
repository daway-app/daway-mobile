enum PatientNotificationType { medicineAvailable, inquiryAnswered, reminder, system, other }

/// Maps the backend's notification `type` string. The patient-facing types
/// are the ones the API's notification filters document (`medicine_available`,
/// `inquiry_answered`, `system`, `reminder`); anything else falls back to
/// [PatientNotificationType.other] rather than crashing on a future type.
PatientNotificationType patientNotificationTypeFrom(String? raw) {
  return switch (raw) {
    'medicine_available' => PatientNotificationType.medicineAvailable,
    'inquiry_answered' => PatientNotificationType.inquiryAnswered,
    'reminder' => PatientNotificationType.reminder,
    'system' => PatientNotificationType.system,
    _ => PatientNotificationType.other,
  };
}

/// A patient-facing notification. The backend's `message` is already a full,
/// ready-to-display sentence — the presentation layer only derives a
/// per-[type] title and category label on top of it.
class PatientNotification {
  final int id;
  final PatientNotificationType type;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const PatientNotification({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });
}
