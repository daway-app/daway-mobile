import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

/// Icon box + title + subtitle shared by [LocationPermissionScreen] and
/// [NotificationsPermissionScreen].
class PermissionIconHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const PermissionIconHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96.w,
          height: 96.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.permissionIconBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.iconBlueBorder, width: 1.0),
          ),
          child: Icon(icon, size: 44.sp, color: AppColors.primaryTeal),
        ),
        SizedBox(height: 24.h),
        Text(title, textAlign: TextAlign.center, style: AppTextStyles.authPermissionTitle),
        SizedBox(height: 16.h),
        Text(subtitle, textAlign: TextAlign.center, style: AppTextStyles.authPermissionSubtitle),
      ],
    );
  }
}
