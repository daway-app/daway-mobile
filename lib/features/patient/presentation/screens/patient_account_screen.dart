import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/cubit/logout_cubit.dart';
import '../cubit/favorite_medicines_cubit.dart';
import '../cubit/patient_notifications_cubit.dart';
import '../cubit/patient_profile_cubit.dart';
import '../widgets/account_row_card.dart';
import 'patient_addresses_screen.dart';
import 'patient_favorites_screen.dart';
import 'patient_notifications_screen.dart';
import 'patient_orders_screen.dart';
import 'patient_profile_screen.dart';
import 'patient_settings_screen.dart';

/// Account hub tab — a menu of account-related destinations. "معلومات
/// الحساب" pushes the real [PatientProfileScreen], "عناويني" pushes
/// [PatientAddressesScreen], "طلباتي" pushes [PatientOrdersScreen],
/// "الادوية المحفوظة" pushes [PatientFavoritesScreen], "الاشعارات" pushes
/// [PatientNotificationsScreen], "الإعدادات" pushes [PatientSettingsScreen];
/// the rest don't have a screen yet, so they just surface a "قريباً" cue like
/// the rest of the app's not-yet-built destinations (see
/// [ComingSoonTabScreen]).
///
/// Logging out is not offered here: it lives only in the settings screen.
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

  void _openOrders(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PatientOrdersScreen()),
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<PatientNotificationsCubit>(),
          child: const PatientNotificationsScreen(),
        ),
      ),
    );
  }

  void _openFavorites(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<FavoriteMedicinesCubit>(),
          child: const PatientFavoritesScreen(),
        ),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      PatientSettingsScreen.route(logoutCubit: context.read<LogoutCubit>()),
    );
  }

  void _comingSoon(BuildContext context) => AppSnackbar.show(context, 'قريباً');

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
              AccountRowCard(
                leading: const AccountRowIcon('assets/icons/user_icon.svg'),
                label: 'معلومات الحساب',
                onTap: () => _openProfile(context),
              ),
              SizedBox(height: 24.h),
              AccountRowCard(
                leading: const AccountRowIcon('assets/icons/order_icon.svg'),
                label: 'طلباتي',
                onTap: () => _openOrders(context),
              ),
              SizedBox(height: 24.h),
              AccountRowCard(
                leading: const AccountRowIcon('assets/icons/bookmark_icon.svg'),
                label: 'الادوية المحفوظة',
                onTap: () => _openFavorites(context),
              ),
              SizedBox(height: 24.h),
              AccountRowCard(
                leading: const AccountRowIcon('assets/icons/place_icon.svg'),
                label: 'عناويني',
                onTap: () => _openAddresses(context),
              ),
              SizedBox(height: 24.h),
              AccountRowCard(
                leading: Icon(Icons.alarm_rounded, color: AppColors.mainTeal, size: 22.sp),
                label: 'تذكيرات الأدوية',
                onTap: () => Navigator.of(context).pushNamed(Routes.medicineRemindersScreen),
              ),
              SizedBox(height: 24.h),
              AccountRowCard(
                leading: Icon(Icons.notifications_outlined, color: AppColors.mainTeal, size: 22.sp),
                label: 'الاشعارات',
                onTap: () => _openNotifications(context),
              ),
              SizedBox(height: 24.h),
              AccountRowCard(
                leading: const AccountRowIcon('assets/icons/headphones_icon.svg'),
                label: 'الدعم الفني',
                onTap: () => _comingSoon(context),
              ),
              SizedBox(height: 24.h),
              AccountRowCard(
                leading: const AccountRowIcon('assets/icons/settings_icon.svg'),
                label: 'الإعدادات',
                onTap: () => _openSettings(context),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
