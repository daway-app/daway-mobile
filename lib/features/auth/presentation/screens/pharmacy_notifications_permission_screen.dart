import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/theming/app_colors.dart';
import '../widgets/notifications_permission_view.dart';
import 'pharmacy_pending_approval_screen.dart';

/// Final step of the pharmacy sign-up flow — mirrors
/// [NotificationsPermissionScreen] from the patient flow via the shared
/// [NotificationsPermissionView]. The account was already created (pending
/// admin approval) back on the sign-up form, so this just requests the OS
/// notification permission (best-effort) and lands on
/// [PharmacyPendingApprovalScreen] — there is no token yet to reach the
/// dashboard with.
class PharmacyNotificationsPermissionScreen extends StatelessWidget {
  const PharmacyNotificationsPermissionScreen({super.key});

  Future<void> _finish(BuildContext context, {required bool requestPermission}) async {
    if (requestPermission) {
      await Permission.notification.request();
    }
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PharmacyPendingApprovalScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: NotificationsPermissionView(
            subtitle: 'فعّل الإشعارات لتصلك تحديثات الطلبات وتنبيهات المخزون المهمة.',
            buttonColor: AppColors.mainTeal,
            onAllow: () => _finish(context, requestPermission: true),
            onSkip: () => _finish(context, requestPermission: false),
          ),
        ),
      ),
    );
  }
}
