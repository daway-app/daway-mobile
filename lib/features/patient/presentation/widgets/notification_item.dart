import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/helpers/smart_date_formatter.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/patient_notification.dart';
import '../helpers/patient_notification_display.dart';

/// One row of the notifications list: an icon box, a title/message/time+chip
/// column, and a dismiss "X". Full-bleed (the screen doesn't pad it) — the
/// hairline divider under it runs edge to edge.
class NotificationItem extends StatelessWidget {
  final PatientNotification notification;
  final VoidCallback onDismissTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onDismissTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.authInputBorder, width: 0.5)),
      ),
      // RTL order (first child is rightmost): icon box, then the text
      // column, then the dismiss "X" at the far left.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 42.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.permissionIconBg,
              border: Border.all(color: AppColors.iconBlueBorder),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: SvgPicture.asset(
              iconAssetFor(notification.type),
              width: 20.r,
              height: 20.r,
              // One tint for every kind: some of the icons ship in grey.
              colorFilter: const ColorFilter.mode(AppColors.mainTeal, BlendMode.srcIn),
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              // `start`, not `end`: this app is RTL, so `start` is the right
              // edge, next to the icon.
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleFor(notification.type),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.notificationTitle,
                ),
                Text(
                  notification.message,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.notificationBody,
                ),
                SizedBox(height: 7.h),
                // A Wrap rather than a Row so a longer chip label or a larger
                // system font flows the time onto a second line instead of
                // overflowing.
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8.w,
                  runSpacing: 4.h,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.permissionIconBg,
                        border: Border.all(color: AppColors.iconBlueBorder),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        categoryLabelFor(notification.type),
                        style: AppTextStyles.notificationChip,
                      ),
                    ),
                    Text(
                      relativeTimeAr(notification.createdAt),
                      style: AppTextStyles.mutedCaption,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onDismissTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Icon(Icons.close, size: 14.sp, color: AppColors.mainTeal),
            ),
          ),
        ],
      ),
    );
  }
}
