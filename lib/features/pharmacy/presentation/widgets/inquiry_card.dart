import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/inquiry.dart';

class InquiryCard extends StatelessWidget {
  final Inquiry inquiry;
  final bool isUpdating;
  final VoidCallback onMarkAnswered;
  final VoidCallback onClose;

  const InquiryCard({
    super.key,
    required this.inquiry,
    required this.isUpdating,
    required this.onMarkAnswered,
    required this.onClose,
  });

  (String, Color, Color) get _statusBadge => switch (inquiry.status) {
    InquiryStatus.newInquiry => ('جديدة', AppColors.success, AppColors.success),
    InquiryStatus.answered => (
      'تم الرد',
      AppColors.primaryTeal,
      AppColors.primaryTeal,
    ),
    InquiryStatus.closed => ('مغلقة', AppColors.grey, AppColors.grey),
  };

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor, badgeColor) = _statusBadge;
    final canMarkAnswered = inquiry.status.canMarkAnswered;
    final canClose = inquiry.status.canClose;
    final medicineName = inquiry.medicineName;

    return AppCard(
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(name: inquiry.patientName),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  inquiry.patientName,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            inquiry.message,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13.5.sp,
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
          if (medicineName != null && medicineName.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    medicineName,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainTeal,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.medication_outlined,
                  size: 14.sp,
                  color: AppColors.mainTeal,
                ),
              ],
            ),
          ],
          SizedBox(height: 8.h),
          Text(
            _smartDate(inquiry.createdAt),
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 11.sp, color: AppColors.grey),
          ),
          SizedBox(height: 12.h),
          if (isUpdating)
            Center(
              child: SizedBox(
                width: 18.w,
                height: 18.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: canClose ? onClose : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      disabledForegroundColor: AppColors.grey,
                      side: BorderSide(
                        color: canClose
                            ? AppColors.error
                            : AppColors.borderGrey,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: const Text('إغلاق'),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: canMarkAnswered ? onMarkAnswered : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainTeal,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.white,
                      disabledForegroundColor: AppColors.grey,
                      elevation: 0,
                      side: canMarkAnswered
                          ? BorderSide.none
                          : BorderSide(color: AppColors.borderGrey),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: const Text('تم الرد'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;

  const _Avatar({required this.name});

  static String _initialsOf(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '؟';
    if (words.length == 1) return words.first.substring(0, 1);
    return words[0].substring(0, 1) + words[1].substring(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: AppColors.lightTeal.withValues(alpha: 0.35),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initialsOf(name),
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.mainTeal,
        ),
      ),
    );
  }
}

const _arabicMonths = [
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

/// "اليوم، 9:40 ص" / "أمس، 4:20 م" / "3 مايو 2025، 11:15 ص" — compares
/// calendar-date components directly (year/month/day), not a Duration
/// subtracted between two DateTimes, so a DST transition day (a real 23h or
/// 25h gap between two local midnights) can't misclassify "today" as
/// "yesterday" or vice versa.
String _smartDate(DateTime dateTime) {
  final now = DateTime.now();
  final time = _formatTime(dateTime);

  if (_isSameDate(dateTime, now)) return 'اليوم، $time';
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  if (_isSameDate(dateTime, yesterday)) return 'أمس، $time';
  return '${dateTime.day} ${_arabicMonths[dateTime.month - 1]} ${dateTime.year}، $time';
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatTime(DateTime dateTime) {
  final isAm = dateTime.hour < 12;
  var hour12 = dateTime.hour % 12;
  if (hour12 == 0) hour12 = 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour12:$minute ${isAm ? 'ص' : 'م'}';
}
