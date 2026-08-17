import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/logout_confirmation_dialog.dart';
import '../../../auth/presentation/cubit/logout_cubit.dart';

/// Drawer shown from [PatientHomeScreen] and the other main patient tabs.
/// Items with no screen yet just close the drawer with a "coming soon" cue
/// instead of silently doing nothing.
class PatientSideMenu extends StatelessWidget {
  const PatientSideMenu({super.key});

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
              onTap: () => Navigator.of(context).pop(),
            ),
            _MenuItem(
              icon: Icons.person_outline,
              label: 'حسابي',
              onTap: () => _handleComingSoon(context),
            ),
            _MenuItem(
              icon: Icons.calendar_month_outlined,
              label: 'مواعيدي',
              onTap: () => _handleComingSoon(context),
            ),
            _MenuItem(
              icon: Icons.medication_outlined,
              label: 'أدويتي',
              onTap: () => _handleComingSoon(context),
            ),
            _MenuItem(
              icon: Icons.settings_outlined,
              label: 'الإعدادات',
              onTap: () => _handleComingSoon(context),
            ),
            _MenuItem(
              icon: Icons.support_agent_outlined,
              label: 'المساعدة والدعم',
              onTap: () => _handleComingSoon(context),
            ),
            const Spacer(),
            Divider(color: AppColors.borderGrey, height: 1),
            _MenuItem(
              icon: Icons.logout,
              label: 'تسجيل الخروج',
              iconColor: AppColors.error,
              labelColor: AppColors.error,
              onTap: () => LogoutConfirmationDialog.show(
                context,
                onConfirm: () => context.read<LogoutCubit>().logout(),
              ),
            ),
            SizedBox(height: 16.h),
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
  final Color? iconColor;
  final Color? labelColor;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.textDark),
      title: Text(
        label,
        textAlign: TextAlign.right,
        style: AppTextStyles.cardDescription.copyWith(
          color: labelColor ?? AppColors.textDark,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }
}
