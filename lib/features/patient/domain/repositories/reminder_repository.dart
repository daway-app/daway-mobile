import '../../../../core/helpers/api_result.dart';
import '../entities/medicine_reminder.dart';

abstract class ReminderRepository {
  Future<ApiResult<List<MedicineReminder>>> getReminders();
  Future<ApiResult<void>> saveReminder(MedicineReminder reminder);
  Future<ApiResult<void>> deleteReminder(String id);
}
