import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/logout_confirmation_dialog.dart';
import '../../../auth/presentation/cubit/logout_cubit.dart';
import '../cubit/patient_profile_cubit.dart';
import 'patient_addresses_screen.dart';
import 'patient_profile_screen.dart';

/// Account hub tab — a menu of account-related destinations. "معلومات
/// الحساب" pushes the real [PatientProfileScreen], "عناويني" pushes
/// [PatientAddressesScreen]; the rest don't have a screen yet, so they just
/// surface a "قريباً" cue like the rest of the app's not-yet-built
/// destinations (see [ComingSoonTabScreen]).
class PatientAccountScreen extends StatelessWidget {
  const PatientAccountScreen({super.key});

  void _openProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<PatientProfileCubit>(),
          child: const PatientProfileScreen(),
        ),
      ),
    );
  }

  void _openAddresses(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PatientAddressesScreen()),
    );
  }

  void _comingSoon(BuildContext context) => AppSnackbar.show(context, 'قريباً');

  void _logout(BuildContext context) => LogoutConfirmationDialog.show(
        context,
        onConfirm: () => context.read<LogoutCubit>().logout(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 32.h),
              Text('أهلاً في حسابك', textAlign: TextAlign.right, style: AppTextStyles.authScreenTitle),
              SizedBox(height: 8.h),
              Text(
                'من هنا بتقدر تدير كل تفاصيل حسابك.',
                textAlign: TextAlign.right,
                style: AppTextStyles.authScreenSubtitle,
              ),
              SizedBox(height: 24.h),
              _AccountMenuRow(
                iconAsset: 'assets/icons/user_icon.svg',
                label: 'معلومات الحساب',
                onTap: () => _openProfile(context),
              ),
              SizedBox(height: 24.h),
              _AccountMenuRow(
                iconAsset: 'assets/icons/order_icon.svg',
                label: 'طلباتي',
                onTap: () => _comingSoon(context),
              ),
              SizedBox(height: 24.h),
              _AccountMenuRow(
                iconAsset: 'assets/icons/bookmark_icon.svg',
                label: 'الادوية المحفوظة',
                onTap: () => _comingSoon(context),
              ),
              SizedBox(height: 24.h),
              _AccountMenuRow(
                iconAsset: 'assets/icons/place_icon.svg',
                label: 'عناويني',
                onTap: () => _openAddresses(context),
              ),
              SizedBox(height: 24.h),
              _AccountMenuRow(
                iconData: Icons.alarm_rounded,
                label: 'تذكيرات الأدوية',
                onTap: () => Navigator.of(context).pushNamed(Routes.medicineRemindersScreen),
              ),
              SizedBox(height: 24.h),
              _AccountMenuRow(
                iconData: Icons.notifications_outlined,
                label: 'الاشعارات',
                onTap: () => _comingSoon(context),
              ),
              SizedBox(height: 24.h),
              _AccountMenuRow(
                iconAsset: 'assets/icons/headphones_icon.svg',
                label: 'الدعم الفني',
                onTap: () => _comingSoon(context),
              ),
              SizedBox(height: 24.h),
              _AccountMenuRow(
                iconAsset: 'assets/icons/settings_icon.svg',
                label: 'الإعدادات',
                onTap: () => _comingSoon(context),
              ),
              SizedBox(height: 24.h),
              _AccountMenuRow(
                iconData: Icons.logout,
                label: 'تسجيل الخروج',
                iconColor: AppColors.error,
                labelColor: AppColors.error,
                onTap: () => _logout(context),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountMenuRow extends StatelessWidget {
  final String? iconAsset;
  final IconData? iconData;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _AccountMenuRow({
    this.iconAsset,
    this.iconData,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  }) : assert(iconAsset != null || iconData != null);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: onTap,
        child: Container(
          height: 56.h,
          padding: EdgeInsets.only(right: 16.w, left: 8.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              iconAsset != null
                  ? SvgPicture.asset(
                      iconAsset!,
                      width: 22.w,
                      height: 22.w,
                      colorFilter: ColorFilter.mode(iconColor ?? AppColors.mainTeal, BlendMode.srcIn),
                    )
                  : Icon(iconData, color: iconColor ?? AppColors.mainTeal, size: 22.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.accountMenuLabel.copyWith(color: labelColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
