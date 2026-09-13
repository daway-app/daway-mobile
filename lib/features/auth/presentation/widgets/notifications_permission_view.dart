import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import 'permission_icon_header.dart';

/// Shared "allow notifications" layout used by both the patient and pharmacy
/// sign-up flows — each screen wires this to its own finishing logic and
/// supplies the copy/color that differs between them.
class NotificationsPermissionView extends StatelessWidget {
  final String subtitle;
  final Color buttonColor;
  final VoidCallback onAllow;
  final VoidCallback onSkip;

  const NotificationsPermissionView({
    super.key,
    required this.subtitle,
    required this.buttonColor,
    required this.onAllow,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 32.h),
          PermissionIconHeader(
            icon: Icons.notifications_none_rounded,
            title: 'ابق على اطلاع دائم',
            subtitle: subtitle,
          ),
          SizedBox(height: 24.h),
          AppCustomButton(
            text: 'السماح بالإشعارات',
            backgroundColor: buttonColor,
            onPressed: onAllow,
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: onSkip,
            child: Text(
              'تخطي',
              textAlign: TextAlign.center,
              style: AppTextStyles.authFooterMuted,
            ),
          ),
        ],
      ),
    );
  }
}
