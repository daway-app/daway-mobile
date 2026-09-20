import '../../../../core/helpers/api_result.dart';
import '../entities/medicine_reminder.dart';
import '../repositories/reminder_repository.dart';

class SaveReminderUseCase {
  final ReminderRepository _repository;

  const SaveReminderUseCase(this._repository);

  Future<ApiResult<void>> call(MedicineReminder reminder) =>
      _repository.saveReminder(reminder);
}
