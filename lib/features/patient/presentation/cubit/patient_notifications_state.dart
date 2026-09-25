import '../../domain/entities/patient_notification.dart';

sealed class PatientNotificationsState {
  const PatientNotificationsState();
}

class PatientNotificationsLoading extends PatientNotificationsState {
  const PatientNotificationsLoading();
}

class PatientNotificationsLoadFailure extends PatientNotificationsState {
  final String message;

  const PatientNotificationsLoadFailure(this.message);
}

class PatientNotificationsLoaded extends PatientNotificationsState {
  final List<PatientNotification> notifications;

  const PatientNotificationsLoaded(this.notifications);
}
