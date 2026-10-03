import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/working_hours_entry.dart';
import '../helpers/working_hours_format.dart';

const _defaultOpen = '09:00';
const _defaultClose = '22:00';

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
        parseWorkingTime(isOpenTime ? entry.open : entry.close) ?? const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    final formatted = formatWorkingTime(picked);
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
            child: Text(weekDayLabels[entry.day]!, style: AppTextStyles.cardDescription),
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
