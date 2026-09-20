import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/medicine_reminder.dart';
import '../../domain/usecases/delete_reminder_usecase.dart';
import '../../domain/usecases/get_reminders_usecase.dart';
import '../../domain/usecases/save_reminder_usecase.dart';
import 'reminders_state.dart';

class RemindersCubit extends Cubit<RemindersState> {
  final GetRemindersUseCase _getRemindersUseCase;
  final SaveReminderUseCase _saveReminderUseCase;
  final DeleteReminderUseCase _deleteReminderUseCase;

  RemindersCubit(
    this._getRemindersUseCase,
    this._saveReminderUseCase,
    this._deleteReminderUseCase,
  ) : super(const RemindersLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const RemindersLoading());
    final result = await _getRemindersUseCase();
    switch (result) {
      case Success(:final data):
        emit(RemindersLoaded(data));
      case ApiError(:final failure):
        emit(RemindersFailure(failure.message));
    }
  }

  Future<void> saveReminder(MedicineReminder reminder) async {
    final result = await _saveReminderUseCase(reminder);
    if (result is ApiError) {
      emit(RemindersFailure(result.failure.message));
      return;
    }
    try {
      await NotificationService.scheduleReminder(reminder);
    } catch (_) {
      // The reminder is already saved; a scheduling failure here shouldn't
      // wipe the list the user just successfully edited.
    }
    await load();
  }

  Future<void> deleteReminder(String id) async {
    final result = await _deleteReminderUseCase(id);
    if (result is ApiError) {
      emit(RemindersFailure(result.failure.message));
      return;
    }
    try {
      await NotificationService.cancelReminder(id);
    } catch (_) {
      // The reminder is already deleted from storage; ignore a scheduler
      // failure so the list still reflects the successful deletion.
    }
    await load();
  }
}
