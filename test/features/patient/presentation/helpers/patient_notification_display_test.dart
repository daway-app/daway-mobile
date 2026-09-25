import 'package:daway_app/features/patient/domain/entities/patient_notification.dart';
import 'package:daway_app/features/patient/presentation/helpers/patient_notification_display.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each notification kind has its own icon, not the shopping bag for everything', () {
    expect(iconAssetFor(PatientNotificationType.medicineAvailable), 'assets/icons/order_icon.svg');
    expect(iconAssetFor(PatientNotificationType.inquiryAnswered), 'assets/icons/massage_icon.svg');
    expect(iconAssetFor(PatientNotificationType.reminder), 'assets/icons/timer_icon.svg');
    expect(iconAssetFor(PatientNotificationType.system), 'assets/icons/bell_icon.svg');
  });

  test('an unknown kind falls back to the bell', () {
    expect(iconAssetFor(PatientNotificationType.other), 'assets/icons/bell_icon.svg');
  });

  test('only system notifications land in a specific tab today', () {
    expect(tabFor(PatientNotificationType.system), PatientNotificationTab.system);
    expect(tabFor(PatientNotificationType.reminder), isNull);
    expect(tabFor(PatientNotificationType.inquiryAnswered), isNull);
  });

  test('every kind has a title and a chip label', () {
    for (final type in PatientNotificationType.values) {
      expect(titleFor(type), isNotEmpty, reason: '$type');
      expect(categoryLabelFor(type), isNotEmpty, reason: '$type');
    }
  });
}
