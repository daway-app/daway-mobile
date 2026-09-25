import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/cubit/logout_cubit.dart';
import '../screens/patient_settings_screen.dart';
import 'patient_dashboard_tab_scope.dart';

/// Drawer shown from every tab inside [PatientDashboardShellScreen] — each
/// tab owns its own instance rather than the shell owning one shared Drawer,
/// so tapping a tab item here switches the shell's selected tab via
/// [PatientDashboardTabScope] instead of pushing a new route ("الإعدادات"
/// pushes [PatientSettingsScreen], which is also where logging out lives).
/// Items with no screen at all yet just close the drawer with a "coming
/// soon" cue.
class PatientSideMenu extends StatelessWidget {
  const PatientSideMenu({super.key});

  void _switchToTab(BuildContext context, PatientDashboardTab tab) {
    Navigator.of(context).pop();
    final scope = PatientDashboardTabScope.maybeOf(context);
    if (scope != null) {
      scope.switchToTab(tab);
    } else {
      AppSnackbar.show(context, 'قريباً');
    }
  }

  void _openSettings(BuildContext context) {
    final navigator = Navigator.of(context);
    final logoutCubit = context.read<LogoutCubit>();
    navigator.pop(); // close the drawer
    navigator.push(PatientSettingsScreen.route(logoutCubit: logoutCubit));
  }

  void _handleComingSoon(BuildContext context) {
    Navigator.of(context).pop();
    AppSnackbar.show(context, 'قريباً');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.h),
            const Center(child: AppLogo(size: 72)),
            SizedBox(height: 16.h),
            _MenuItem(
              icon: Icons.home_outlined,
              label: 'الرئيسية',
              onTap: () => _switchToTab(context, PatientDashboardTab.home),
            ),
            _MenuItem(
              icon: Icons.search,
              label: 'البحث',
              onTap: () => _switchToTab(context, PatientDashboardTab.search),
            ),
            _MenuItem(
              icon: Icons.chat_bubble_outline,
              label: 'المراسلات',
              onTap: () => _switchToTab(context, PatientDashboardTab.messages),
            ),
            _MenuItem(
              icon: Icons.person_outline,
              label: 'الملف الشخصي',
              onTap: () => _switchToTab(context, PatientDashboardTab.profile),
            ),
            _MenuItem(
              icon: Icons.settings_outlined,
              label: 'الإعدادات',
              onTap: () => _openSettings(context),
            ),
            _MenuItem(
              icon: Icons.support_agent_outlined,
              label: 'المساعدة والدعم',
              onTap: () => _handleComingSoon(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textDark),
      title: Text(
        label,
        textAlign: TextAlign.right,
        style: AppTextStyles.cardDescription.copyWith(
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }
}
