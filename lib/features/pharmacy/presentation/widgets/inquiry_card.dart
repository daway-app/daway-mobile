import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/smart_date_formatter.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/initials_avatar.dart';
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
              InitialsAvatar(name: inquiry.patientName),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  inquiry.patientName,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.personName,
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
            smartDate(inquiry.createdAt),
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

