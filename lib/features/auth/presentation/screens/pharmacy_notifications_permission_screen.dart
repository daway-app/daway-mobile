import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../widgets/notifications_permission_view.dart';

/// Final step of the pharmacy sign-up flow — mirrors
/// [NotificationsPermissionScreen] from the patient flow via the shared
/// [NotificationsPermissionView]. There is no pharmacy registration endpoint
/// yet, so no session is ever saved here; rather than landing on the
/// authenticated dashboard with no token, this sends the pharmacy back to
/// the login screen once the create-account API exists it will be called
/// here with the details collected on [PharmacySignUpCubit], and this can
/// route to [Routes.pharmacyHomeScreen] with a real saved session instead.
class PharmacyNotificationsPermissionScreen extends StatelessWidget {
  const PharmacyNotificationsPermissionScreen({super.key});

  Future<void> _finish(BuildContext context, {required bool requestPermission}) async {
    if (requestPermission) {
      await Permission.notification.request();
    }
    if (!context.mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(Routes.pharmacyAuthScreen, (route) => false);
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
