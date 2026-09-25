import 'package:daway_app/features/patient/data/models/patient_notification_model.dart';
import 'package:daway_app/features/patient/domain/entities/patient_notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a notification JSON object', () {
    final entity = PatientNotificationModel.fromJson({
      'id': 4,
      'type': 'inquiry_answered',
      'message': 'ردّت صيدلية النور على استفسارك',
      'is_read': false,
      'created_at': '2026-09-24T07:41:55.000000Z',
    }).toEntity();

    expect(entity.id, 4);
    expect(entity.type, PatientNotificationType.inquiryAnswered);
    expect(entity.message, 'ردّت صيدلية النور على استفسارك');
    expect(entity.isRead, isFalse);
    expect(entity.createdAt.isAtSameMomentAs(DateTime.utc(2026, 9, 24, 7, 41, 55)), isTrue);
  });

  test('created_at is converted to local time, since the server sends UTC', () {
    // Left as a UTC DateTime it would be compared and printed as if it were
    // the device's local time, hours off from what the user sees on the clock.
    PatientNotification parse(String createdAt) => PatientNotificationModel.fromJson({
          'id': 1,
          'type': 'system',
          'message': 'x',
          'created_at': createdAt,
        }).toEntity();

    expect(parse('2026-09-24T16:08:09.000000Z').createdAt.isUtc, isFalse);
    expect(
      parse('2026-09-24 16:08:09').createdAt.isAtSameMomentAs(DateTime.utc(2026, 9, 24, 16, 8, 9)),
      isTrue,
      reason: 'a zone-less value is the same UTC server clock',
    );
  });

  test('maps each documented patient type, and anything else to "other"', () {
    expect(patientNotificationTypeFrom('medicine_available'), PatientNotificationType.medicineAvailable);
    expect(patientNotificationTypeFrom('inquiry_answered'), PatientNotificationType.inquiryAnswered);
    expect(patientNotificationTypeFrom('reminder'), PatientNotificationType.reminder);
    expect(patientNotificationTypeFrom('system'), PatientNotificationType.system);
    expect(patientNotificationTypeFrom('some_future_type'), PatientNotificationType.other);
    expect(patientNotificationTypeFrom(null), PatientNotificationType.other);
  });

  test('a non-string type degrades to "other" instead of failing the record', () {
    final entity = PatientNotificationModel.fromJson({
      'id': 1,
      'type': 7,
      'message': 'x',
      'created_at': '2026-09-24T07:41:55.000000Z',
    }).toEntity();

    expect(entity.type, PatientNotificationType.other);
  });

  test('reads is_read as either a boolean or a 0/1 integer', () {
    PatientNotification parse(Object? isRead) => PatientNotificationModel.fromJson({
          'id': 1,
          'type': 'system',
          'message': 'x',
          'is_read': isRead,
          'created_at': '2026-09-24T07:41:55.000000Z',
        }).toEntity();

    expect(parse(true).isRead, isTrue);
    expect(parse(1).isRead, isTrue);
    expect(parse(false).isRead, isFalse);
    expect(parse(0).isRead, isFalse);
    expect(parse(null).isRead, isFalse);
  });

  test('a record without an id or created_at throws (so the repository can skip it)', () {
    expect(
      () => PatientNotificationModel.fromJson({'type': 'system', 'created_at': '2026-09-24T00:00:00Z'}),
      throwsA(anything),
    );
    expect(
      () => PatientNotificationModel.fromJson({'id': 1, 'type': 'system'}),
      throwsA(anything),
    );
  });
}
