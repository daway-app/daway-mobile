import '../../../../core/helpers/api_result.dart';
import '../entities/medicine_reminder.dart';
import '../repositories/reminder_repository.dart';

class GetRemindersUseCase {
  final ReminderRepository _repository;

  const GetRemindersUseCase(this._repository);

  Future<ApiResult<List<MedicineReminder>>> call() => _repository.getReminders();
}
