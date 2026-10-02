import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/medicine_reminder.dart';
import '../cubit/reminders_cubit.dart';
import '../widgets/patient_sub_screen_header.dart';

/// "إضافة تذكير للدواء" — a full screen (redesigned 2026-09-28 from a
/// bottom sheet), reused for editing too: [existing] pre-fills the fields
/// and swaps the header/delete affordance in, same dual-purpose the sheet
/// had. Expects a [RemindersCubit] already in context (pushed from
/// [MedicineRemindersScreen] with `BlocProvider.value`).
class AddMedicineReminderScreen extends StatefulWidget {
  final MedicineReminder? existing;

  const AddMedicineReminderScreen({super.key, this.existing});

  @override
  State<AddMedicineReminderScreen> createState() => _AddMedicineReminderScreenState();
}

class _AddMedicineReminderScreenState extends State<AddMedicineReminderScreen> {
  late final TextEditingController _nameController;
  late ReminderFrequency _frequency;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _frequency = existing?.frequency ?? ReminderFrequency.daily;
    _selectedTime =
        existing == null ? null : TimeOfDay(hour: existing.hour, minute: existing.minute);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null && mounted) setState(() => _selectedTime = time);
  }

  void _save() {
    final name = _nameController.text.trim();
    final time = _selectedTime;
    if (name.isEmpty || time == null) return;

    final reminder = MedicineReminder(
      id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      frequency: _frequency,
      hour: time.hour,
      minute: time.minute,
    );
    context.read<RemindersCubit>().saveReminder(reminder);
    Navigator.of(context).pop();
  }

  void _delete() {
    final existing = widget.existing;
    if (existing == null) return;
    context.read<RemindersCubit>().deleteReminder(existing.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PatientSubScreenHeader(
                title: isEditing ? 'تعديل التذكير' : 'إضافة تذكير للدواء',
                description: 'أضف الادوية لتذكيرك فيها بالوقت المناسب',
              ),
              SizedBox(height: 24.h),
              Text('اسم الدواء', textAlign: TextAlign.right, style: AppTextStyles.profileFieldLabel),
              SizedBox(height: 8.h),
              AppTextField(
                controller: _nameController,
                hintText: '',
                fillColor: Colors.white,
              ),
              SizedBox(height: 24.h),
              Text(
                'مواعيد التذكير',
                textAlign: TextAlign.right,
                style: AppTextStyles.profileFieldLabel,
              ),
              SizedBox(height: 8.h),
              // Wrap, not Row: three chips at a real Tajawal width don't
              // reliably fit one 392-wide line (a RenderFlex overflow this
              // caught during testing) — Wrap falls back to a second line
              // instead of clipping.
              Wrap(
                alignment: WrapAlignment.start,
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  // First = rightmost under this app's RTL directionality
                  // (same convention as FavoriteMedicineCard's thumbnail) —
                  // "كل يوم" belongs on the right.
                  for (final frequency in [
                    ReminderFrequency.daily,
                    ReminderFrequency.every12Hours,
                    ReminderFrequency.every6Hours,
                  ])
                    _FrequencyChip(
                      label: frequency.chipLabel,
                      selected: _frequency == frequency,
                      onTap: () => setState(() => _frequency = frequency),
                    ),
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                'وقت التذكير',
                textAlign: TextAlign.right,
                style: AppTextStyles.profileFieldLabel,
              ),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  height: 54.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedTime == null ? '' : _formatTime(_selectedTime!),
                          textAlign: TextAlign.right,
                          style: AppTextStyles.profileFieldValue,
                        ),
                      ),
                      Icon(Icons.access_time_rounded, size: 20.sp, color: AppColors.mainTeal),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              if (isEditing) ...[
                OutlinedButton(
                  onPressed: _delete,
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 56.h),
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(
                    'حذف',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
              AppCustomButton(text: 'التالي', onPressed: _save),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

/// Matches [MedicineReminder.formattedTime]'s format, for the time picker
/// field's display before a reminder object even exists to ask.
String _formatTime(TimeOfDay time) {
  final period = time.hour < 12 ? 'ص' : 'م';
  final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
  return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
}

class _FrequencyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FrequencyChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Fixed, not sized by its text: on a real device the three chips
        // were wrapping onto separate lines instead of sitting in one row
        // (a Wrap forced there earlier to stop a different overflow) —
        // fixed at 69x53 they comfortably fit one row regardless.
        width: 69.w,
        height: 53.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.mainTeal : Colors.white,
          borderRadius: BorderRadius.circular(9.r),
          border: selected ? null : Border.all(color: AppColors.cardBorder),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : AppColors.onboardingText,
            ),
          ),
        ),
      ),
    );
  }
}
