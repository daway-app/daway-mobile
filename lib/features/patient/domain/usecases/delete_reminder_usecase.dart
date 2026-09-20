import '../../../../core/helpers/api_result.dart';
import '../repositories/reminder_repository.dart';

class DeleteReminderUseCase {
  final ReminderRepository _repository;

  const DeleteReminderUseCase(this._repository);

  Future<ApiResult<void>> call(String id) => _repository.deleteReminder(id);
}
