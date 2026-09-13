import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../widgets/notifications_permission_view.dart';

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
          child: NotificationsPermissionView(
            subtitle: 'فعّل الإشعارات لتصلك تحديثات طلباتك وتنبيهات الأدوية المهمة.',
            buttonColor: AppColors.primaryTeal,
            onAllow: () => _finish(context, requestPermission: true),
            onSkip: () => _finish(context, requestPermission: false),
          ),
        ),
      ),
    );
  }
}
