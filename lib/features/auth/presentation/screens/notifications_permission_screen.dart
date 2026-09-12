import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../widgets/permission_icon_header.dart';

/// Final step of the sign-up flow, reached once OTP verification succeeded
/// (the account already exists at this point) — best-effort OS notification
/// permission request, then straight to the home screen.
class NotificationsPermissionScreen extends StatelessWidget {
  const NotificationsPermissionScreen({super.key});

  Future<void> _finish(BuildContext context, {required bool requestPermission}) async {
    if (requestPermission) {
      await Permission.notification.request();
    }
    if (!context.mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(Routes.patientHomeScreen, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 32.h),
                const PermissionIconHeader(
                  icon: Icons.notifications_none_rounded,
                  title: 'ابق على اطلاع دائم',
                  subtitle: 'فعّل الإشعارات لتصلك تحديثات طلباتك وتنبيهات الأدوية المهمة.',
                ),
                SizedBox(height: 24.h),
                AppCustomButton(
                  text: 'السماح بالإشعارات',
                  backgroundColor: AppColors.primaryTeal,
                  onPressed: () => _finish(context, requestPermission: true),
                ),
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: () => _finish(context, requestPermission: false),
                  child: Text(
                    'تخطي',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.authFooterMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
