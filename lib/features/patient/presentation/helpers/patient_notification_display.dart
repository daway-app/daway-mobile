import '../../domain/entities/patient_notification.dart';

/// The filter tabs on the notifications screen.
enum PatientNotificationTab { all, orders, offers, system }

/// Which tab (besides "الكل") a notification belongs under, or null when it
/// only appears under "الكل". The design's "الطلبات" and "العروض" tabs are for
/// notification types the backend doesn't emit yet (there are no orders or
/// offers), so today only `system` notifications land in a specific tab.
PatientNotificationTab? tabFor(PatientNotificationType type) {
  return switch (type) {
    PatientNotificationType.system => PatientNotificationTab.system,
    _ => null,
  };
}

/// The backend sends a ready-made sentence but no title, so the bold title
/// line is derived from the type.
String titleFor(PatientNotificationType type) {
  return switch (type) {
    PatientNotificationType.medicineAvailable => 'دواء متوفر',
    PatientNotificationType.inquiryAnswered => 'تم الرد على استفسارك',
    PatientNotificationType.reminder => 'تذكير بموعد دوائك',
    PatientNotificationType.system => 'إشعار من النظام',
    PatientNotificationType.other => 'إشعار جديد',
  };
}

/// The small category chip on a notification.
String categoryLabelFor(PatientNotificationType type) {
  return switch (type) {
    PatientNotificationType.medicineAvailable => 'الأدوية',
    PatientNotificationType.inquiryAnswered => 'الاستفسارات',
    PatientNotificationType.reminder => 'التذكيرات',
    PatientNotificationType.system => 'النظام',
    PatientNotificationType.other => 'عام',
  };
}

/// The icon in the box at the start of a notification. The design draws the
/// shopping bag for the medicine-availability kind (buy it now); the other
/// kinds get a fitting icon of their own, so a reminder or a pharmacy's answer
/// is not mistaken for an order update.
String iconAssetFor(PatientNotificationType type) {
  return switch (type) {
    PatientNotificationType.medicineAvailable => 'assets/icons/order_icon.svg',
    PatientNotificationType.inquiryAnswered => 'assets/icons/massage_icon.svg',
    PatientNotificationType.reminder => 'assets/icons/timer_icon.svg',
    PatientNotificationType.system || PatientNotificationType.other => 'assets/icons/bell_icon.svg',
  };
}
