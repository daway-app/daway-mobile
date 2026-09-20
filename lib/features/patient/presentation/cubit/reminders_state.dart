import '../../domain/entities/medicine_reminder.dart';

sealed class RemindersState {
  const RemindersState();
}

class RemindersLoading extends RemindersState {
  const RemindersLoading();
}

class RemindersLoaded extends RemindersState {
  final List<MedicineReminder> reminders;
  const RemindersLoaded(this.reminders);
}

class RemindersFailure extends RemindersState {
  final String message;
  const RemindersFailure(this.message);
}
