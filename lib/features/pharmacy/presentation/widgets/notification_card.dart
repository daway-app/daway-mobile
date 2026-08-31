import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/smart_date_formatter.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../domain/entities/notification.dart';
import '../helpers/notification_display.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onAction;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onAction,
  });

  (String, Color)? get _action => switch (notification.type) {
    NotificationType.outOfStock => ('عاجل', AppColors.error),
    NotificationType.lowStock => ('تحديث المخزون', AppColors.warning),
    NotificationType.newInquiry => ('عرض الاستفسار', AppColors.primaryTeal),
    NotificationType.newRating || NotificationType.other => null,
  };

  @override
  Widget build(BuildContext context) {
    final display = notificationDisplayFor(notification.type);
    final action = _action;

    return AppCard(
      padding: EdgeInsets.all(14.r),
      color: notification.isRead
          ? Colors.white
          : AppColors.lightTeal.withValues(alpha: 0.15),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: display.icon, color: display.color, size: 44),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        display.title,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.personName,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    if (!notification.isRead) ...[
                      Container(
                        width: 6.w,
                        height: 6.w,
                        margin: EdgeInsets.only(top: 5.h, left: 4.w),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryTeal,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                    Text(
                      relativeTimeAr(notification.createdAt),
                      style: TextStyle(fontSize: 11.sp, color: AppColors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  notification.message,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.cardDescription,
                ),
                if (action != null) ...[
                  SizedBox(height: 10.h),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: OutlinedButton(
                      onPressed: onAction,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: action.$2,
                        side: BorderSide(color: action.$2),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 6.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      child: Text(
                        action.$1,
                        style: TextStyle(fontSize: 12.5.sp),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
