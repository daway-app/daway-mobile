import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_colors.dart';

/// Tap-to-open field backed by [showDatePicker]. Stores/returns the date as
/// an ISO 'YYYY-MM-DD' string (what the API expects for birth_date), so
/// callers don't need date-formatting logic of their own.
class BirthDateField extends StatelessWidget {
  final String? birthDate;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const BirthDateField({
    super.key,
    required this.birthDate,
    required this.enabled,
    required this.onChanged,
  });

  static String _format(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  DateTime? _parse(String? value) {
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _parse(birthDate) ?? DateTime(now.year - 20),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );
    if (picked == null) return;
    onChanged(_format(picked));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: enabled ? () => _pickDate(context) : null,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Icon(Icons.cake_outlined, color: AppColors.grey, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                birthDate ?? 'اختر تاريخ ميلادك',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: birthDate != null ? AppColors.textDark : AppColors.grey,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
