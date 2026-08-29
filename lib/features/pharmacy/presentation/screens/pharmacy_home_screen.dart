import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../auth/presentation/cubit/logout_cubit.dart';
import '../../../auth/presentation/cubit/logout_state.dart';
import '../../domain/entities/inquiry.dart';
import '../../domain/entities/pharmacy_dashboard_stats.dart';
import '../cubit/pharmacy_dashboard_cubit.dart';
import '../cubit/pharmacy_dashboard_state.dart';
import '../widgets/pharmacy_dashboard_tab_scope.dart';
import '../widgets/pharmacy_side_menu.dart';

class PharmacyHomeScreen extends StatelessWidget {
  const PharmacyHomeScreen({super.key});

  Future<void> _openAddMedicine(BuildContext context) async {
    final added = await Navigator.of(
      context,
    ).pushNamed(Routes.addPharmacyMedicineScreen);
    if (added == true && context.mounted) {
      context.read<PharmacyDashboardCubit>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const PharmacySideMenu(),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'الصفحة الرئيسية',
          style: AppTextStyles.screenTitle.copyWith(
            color: AppColors.mainTeal,
            fontSize: 20.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: AppColors.mainTeal),
            onPressed: () => AppSnackbar.show(context, 'قريباً'),
          ),
        ],
      ),
      body: BlocListener<LogoutCubit, LogoutState>(
        listenWhen: (previous, current) =>
            !previous.isLoggedOut && current.isLoggedOut,
        listener: (context, state) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(Routes.accountTypeScreen, (route) => false);
        },
        child: SafeArea(
          child: BlocBuilder<PharmacyDashboardCubit, PharmacyDashboardState>(
            builder: (context, state) {
              return switch (state) {
                PharmacyDashboardLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                PharmacyDashboardLoadFailure(:final message) =>
                  ProfileLoadError(
                    message: message,
                    onRetry: () =>
                        context.read<PharmacyDashboardCubit>().load(),
                  ),
                PharmacyDashboardLoaded(:final stats) => _buildLoaded(
                  context,
                  stats,
                ),
              };
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, PharmacyDashboardStats stats) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
      children: [
        Text(
          'أهلاً بك، إليك نظرة سريعة على صيدليتك اليوم',
          style: AppTextStyles.cardDescription,
          textAlign: TextAlign.right,
        ),
        SizedBox(height: 16.h),
        StatCardRow(
          cards: [
            StatCard(
              icon: Icons.medication_outlined,
              color: AppColors.mainTeal,
              value: '${stats.totalMedicines}',
              label: 'إجمالي الأدوية',
            ),
            StatCard(
              icon: Icons.check_circle_outline,
              color: AppColors.success,
              value: '${stats.availableCount}',
              label: 'متوفر',
            ),
            StatCard(
              icon: Icons.trending_down,
              color: AppColors.warning,
              value: '${stats.lowStockCount}',
              label: 'مخزون منخفض',
            ),
            StatCard(
              icon: Icons.remove_circle_outline,
              color: AppColors.error,
              value: '${stats.outOfStockCount}',
              label: 'نافد',
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          'إجراءات سريعة',
          style: AppTextStyles.cardTitle.copyWith(fontSize: 16.sp),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.sync,
                iconColor: AppColors.success,
                title: 'تحديث المخزون',
                subtitle: 'تحديث كميات الأدوية في المخزون',
                onTap: () =>
                    PharmacyDashboardTabScope.switchToTabOrShowComingSoon(
                      context,
                      PharmacyDashboardTab.inventory,
                    ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add,
                iconColor: AppColors.mainTeal,
                title: 'إضافة دواء',
                subtitle: 'إضافة دواء جديد إلى المخزون',
                onTap: () => _openAddMedicine(context),
              ),
            ),
          ],
        ),
        if (stats.lowStockItems.isNotEmpty) ...[
          SizedBox(height: 16.h),
          _LowStockBanner(
            items: stats.lowStockItems,
            lowStockCount: stats.lowStockCount,
            onViewDetails: () =>
                PharmacyDashboardTabScope.switchToTabOrShowComingSoon(
                  context,
                  PharmacyDashboardTab.inventory,
                ),
          ),
        ],
        SizedBox(height: 16.h),
        StatCardRow(
          cards: [
            StatCard(
              icon: Icons.chat_bubble_outline,
              color: AppColors.primaryTeal,
              value: '${stats.newInquiriesCount}',
              label: 'استفسارات جديدة',
              onTap: () =>
                  PharmacyDashboardTabScope.switchToTabOrShowComingSoon(
                    context,
                    PharmacyDashboardTab.inquiries,
                  ),
            ),
            StatCard(
              icon: Icons.star_rounded,
              color: AppColors.warning,
              value: stats.averageRating?.toStringAsFixed(1) ?? '—',
              label: 'متوسط التقييم',
              sublabel: stats.ratingsCount > 0
                  ? '${stats.ratingsCount} تقييم'
                  : 'لا توجد تقييمات بعد',
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          'أحدث الاستفسارات',
          style: AppTextStyles.cardTitle.copyWith(fontSize: 16.sp),
          textAlign: TextAlign.right,
        ),
        SizedBox(height: 12.h),
        AppCard(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          child: stats.recentInquiries.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text(
                    'لا توجد استفسارات بعد',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.cardDescription,
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < stats.recentInquiries.length; i++) ...[
                      if (i > 0)
                        Divider(height: 1, color: AppColors.borderGrey),
                      _RecentInquiryTile(inquiry: stats.recentInquiries[i]),
                    ],
                  ],
                ),
        ),
        SizedBox(height: 8.h),
        Center(
          child: TextButton(
            onPressed: () =>
                PharmacyDashboardTabScope.switchToTabOrShowComingSoon(
                  context,
                  PharmacyDashboardTab.inquiries,
                ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'عرض جميع الاستفسارات',
                  style: TextStyle(
                    color: AppColors.mainTeal,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.arrow_back, size: 14.sp, color: AppColors.mainTeal),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: AppCard(
        padding: EdgeInsets.all(12.r),
        child: Row(
          children: [
            IconBadge(icon: icon, color: iconColor),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: AppColors.grey,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LowStockBanner extends StatelessWidget {
  final List<PharmacyDashboardLowStockItem> items;

  /// The authoritative low-stock count from the stats endpoint (`low_count`)
  /// — used for the "N more" tally instead of `items.length` because
  /// `low_stock_items` is only described as "enough to surface an alert",
  /// not guaranteed to list every low-stock medicine.
  final int lowStockCount;
  final VoidCallback onViewDetails;

  const _LowStockBanner({
    required this.items,
    required this.lowStockCount,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final first = items.first;
    final extraCount = lowStockCount > 1 ? lowStockCount - 1 : 0;
    final suffix = extraCount > 0
        ? '، و${_arabicCount(extraCount, 'دواء آخر', 'أدوية أخرى')} بحاجة لمراجعة.'
        : '.';
    final message =
        'دواء ${first.tradeName} يقترب من حد المخزون الأدنى. الكمية المتبقية: ${first.quantity} عبوة$suffix';

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IconBadge(
            icon: Icons.trending_down,
            color: AppColors.error,
            size: 40,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تنبيه مخزون منخفض',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  message,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.greyText,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 10.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: onViewDetails,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 6.h,
                      ),
                    ),
                    child: const Text('عرض التفاصيل'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentInquiryTile extends StatelessWidget {
  final Inquiry inquiry;

  const _RecentInquiryTile({required this.inquiry});

  Color get _statusColor => switch (inquiry.status) {
    InquiryStatus.newInquiry => AppColors.primaryTeal,
    InquiryStatus.answered => AppColors.success,
    InquiryStatus.closed => AppColors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final medicineName = inquiry.medicineName;
    final subtitle = [
      if (inquiry.patientName.isNotEmpty) 'من: ${inquiry.patientName}',
      if (medicineName != null && medicineName.isNotEmpty) medicineName,
      _relativeArabicTime(inquiry.createdAt),
    ].join(' · ');

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: _statusColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inquiry.message,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainTeal,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp, color: AppColors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A negative `difference` (clock skew, or a `created_at` the backend sent
/// in a different timezone than this device's local one) falls through to
/// the `inMinutes < 1` branch same as a genuinely brand-new inquiry — "الآن"
/// is the safest reading available without knowing the server's true
/// timezone, rather than surfacing a nonsensical negative count.
///
/// Matches the "منذ X أيام" relative-time style the pharmacy web dashboard
/// already uses for inquiry timestamps, rather than a raw calendar date.
String _relativeArabicTime(DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);
  if (difference.inMinutes < 1) return 'الآن';
  if (difference.inMinutes < 60) {
    return 'منذ ${_arabicCount(difference.inMinutes, 'دقيقة', 'دقائق')}';
  }
  if (difference.inHours < 24) {
    return 'منذ ${_arabicCount(difference.inHours, 'ساعة', 'ساعات')}';
  }
  if (difference.inDays < 30) {
    return 'منذ ${_arabicCount(difference.inDays, 'يوم', 'أيام')}';
  }
  final months = (difference.inDays / 30).floor();
  return 'منذ ${_arabicCount(months, 'شهر', 'أشهر')}';
}

/// Deliberately simple (singular vs. one generic plural, no dual form) —
/// good enough for a short home-screen preview, not a general-purpose i18n
/// formatter. Shared by [_relativeArabicTime] and [_LowStockBanner] so the
/// two don't drift if this gets a proper plural form later.
String _arabicCount(int count, String singular, String plural) {
  return '$count ${count == 1 ? singular : plural}';
}
