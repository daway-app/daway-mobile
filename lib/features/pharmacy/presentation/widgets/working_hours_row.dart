import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/working_hours_entry.dart';

const _dayLabels = {
  WeekDay.sat: 'السبت',
  WeekDay.sun: 'الأحد',
  WeekDay.mon: 'الاثنين',
  WeekDay.tue: 'الثلاثاء',
  WeekDay.wed: 'الأربعاء',
  WeekDay.thu: 'الخميس',
  WeekDay.fri: 'الجمعة',
};

const _defaultOpen = '09:00';
const _defaultClose = '22:00';

TimeOfDay? _parseTime(String? value) {
  if (value == null) return null;
  final parts = value.split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

String _formatTime(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

class WorkingHoursRow extends StatelessWidget {
  final WorkingHoursEntry entry;
  final bool isEditing;
  final void Function(String? open, String? close) onChanged;

  const WorkingHoursRow({
    super.key,
    required this.entry,
    required this.isEditing,
    required this.onChanged,
  });

  Future<void> _pickTime(BuildContext context, {required bool isOpenTime}) async {
    final initial =
        _parseTime(isOpenTime ? entry.open : entry.close) ?? const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    final formatted = _formatTime(picked);
    onChanged(
      isOpenTime ? formatted : entry.open,
      isOpenTime ? entry.close : formatted,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          SizedBox(
            width: 60.w,
            child: Text(_dayLabels[entry.day]!, style: AppTextStyles.cardDescription),
          ),
          Expanded(
            child: entry.isOpen
                ? Row(
                    children: [
                      Expanded(
                        child: _TimeChip(
                          label: entry.open!,
                          enabled: isEditing,
                          onTap: () => _pickTime(context, isOpenTime: true),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_right_alt_outlined, size: 14.sp, color: AppColors.grey),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _TimeChip(
                          label: entry.close!,
                          enabled: isEditing,
                          onTap: () => _pickTime(context, isOpenTime: false),
                        ),
                      ),
                    ],
                  )
                : Text('مغلق', style: AppTextStyles.helperText),
          ),
          Switch(
            value: entry.isOpen,
            activeThumbColor: AppColors.mainTeal,
            onChanged: isEditing
                ? (value) => onChanged(
                      value ? _defaultOpen : null,
                      value ? _defaultClose : null,
                    )
                : null,
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _TimeChip({required this.label, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.borderGrey),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: AppColors.textDark),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
