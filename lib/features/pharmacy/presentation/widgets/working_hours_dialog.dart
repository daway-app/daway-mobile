import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/app_toggle_switch.dart';
import '../../domain/entities/working_hours_entry.dart';
import '../helpers/working_hours_format.dart';

const _defaultOpen = '09:00';
const _defaultClose = '22:00';

/// The dialog that edits the whole week's opening hours: for each day, a
/// switch (open or closed) and the hour it opens and closes. Pops with the
/// edited list when the pharmacy confirms, or null when it cancels.
class WorkingHoursDialog extends StatefulWidget {
  final List<WorkingHoursEntry> initial;

  const WorkingHoursDialog({super.key, required this.initial});

  static Future<List<WorkingHoursEntry>?> show(
    BuildContext context, {
    required List<WorkingHoursEntry> initial,
  }) {
    return showDialog<List<WorkingHoursEntry>>(
      context: context,
      builder: (_) => WorkingHoursDialog(initial: initial),
    );
  }

  @override
  State<WorkingHoursDialog> createState() => _WorkingHoursDialogState();
}

class _WorkingHoursDialogState extends State<WorkingHoursDialog> {
  late List<WorkingHoursEntry> _entries;

  @override
  void initState() {
    super.initState();
    // Every day is listed, in the week's order, even if the saved profile
    // came back without one of them.
    _entries = [
      for (final day in WeekDay.values)
        widget.initial.firstWhere(
          (entry) => entry.day == day,
          orElse: () => WorkingHoursEntry(day: day),
        ),
    ];
  }

  void _update(WeekDay day, {String? open, String? close}) {
    setState(() {
      _entries = [
        for (final entry in _entries)
          if (entry.day == day)
            WorkingHoursEntry(day: day, open: open, close: close)
          else
            entry,
      ];
    });
  }

  Future<void> _pickTime(
    WorkingHoursEntry entry, {
    required bool isOpenTime,
  }) async {
    final initial =
        parseWorkingTime(isOpenTime ? entry.open : entry.close) ??
        const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) return;
    final formatted = formatWorkingTime(picked);
    _update(
      entry.day,
      open: isOpenTime ? formatted : entry.open,
      close: isOpenTime ? entry.close : formatted,
    );
  }

  /// An open day whose opening and closing hour are the same would be a
  /// zero-length day.
  bool get _isValid =>
      _entries.every((entry) => !entry.isOpen || entry.open != entry.close);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ساعات العمل',
              textAlign: TextAlign.right,
              style: AppTextStyles.profileFieldLabel,
            ),
            SizedBox(height: 4.h),
            Text(
              'حدد ساعة الفتح والإغلاق لكل يوم',
              textAlign: TextAlign.right,
              style: AppTextStyles.settingsMutedText,
            ),
            SizedBox(height: 16.h),
            for (final entry in _entries)
              _DayRow(
                key: ValueKey(entry.day),
                entry: entry,
                onToggle: () => entry.isOpen
                    ? _update(entry.day)
                    : _update(
                        entry.day,
                        open: _defaultOpen,
                        close: _defaultClose,
                      ),
                onPickOpen: () => _pickTime(entry, isOpenTime: true),
                onPickClose: () => _pickTime(entry, isOpenTime: false),
              ),
            SizedBox(height: 20.h),
            AppCustomButton(
              text: 'تم',
              backgroundColor: _isValid
                  ? AppColors.mainTeal
                  : AppColors.borderGrey,
              onPressed: _isValid
                  ? () => Navigator.of(context).pop(_entries)
                  : () {},
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'إلغاء',
                style: AppTextStyles.settingsMutedText.copyWith(
                  color: AppColors.mainTeal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final WorkingHoursEntry entry;
  final VoidCallback onToggle;
  final VoidCallback onPickOpen;
  final VoidCallback onPickClose;

  const _DayRow({
    super.key,
    required this.entry,
    required this.onToggle,
    required this.onPickOpen,
    required this.onPickClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        // RTL: the day first (rightmost), the switch last (leftmost).
        children: [
          SizedBox(
            width: 64.w,
            child: Text(
              weekDayLabels[entry.day]!,
              style: AppTextStyles.profileFieldValue,
            ),
          ),
          Expanded(
            child: entry.isOpen
                ? Row(
                    children: [
                      Expanded(
                        child: _TimeChip(
                          prefix: 'من',
                          label: formatWorkingTimeArabic(entry.open!),
                          onTap: onPickOpen,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _TimeChip(
                          prefix: 'إلى',
                          label: formatWorkingTimeArabic(entry.close!),
                          onTap: onPickClose,
                        ),
                      ),
                    ],
                  )
                : Text('مغلق', style: AppTextStyles.settingsMutedText),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: AppToggleSwitch(value: entry.isOpen),
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String prefix;
  final String label;
  final VoidCallback onTap;

  const _TimeChip({
    required this.prefix,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 36.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.permissionIconBg,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.iconBlueBorder, width: 0.8),
        ),
        child: Text(
          '$prefix $label',
          maxLines: 1,
          style: AppTextStyles.profileFieldValue.copyWith(fontSize: 13.sp),
        ),
      ),
    );
  }
}
