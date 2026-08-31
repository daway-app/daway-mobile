import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_filter_chip.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../../domain/entities/notification.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';
import '../widgets/notification_card.dart';
import '../widgets/pharmacy_dashboard_tab_scope.dart';

/// Pushed on top of the shell rather than being one of its tabs, so an
/// action button that should jump to a specific tab (e.g. "تحديث المخزون")
/// pops this screen with that [PharmacyDashboardTab] as the result — the
/// caller (the bell icon that pushed this screen, itself inside the shell)
/// is what actually switches tabs, since it's the one with
/// [PharmacyDashboardTabScope] in its context.
class PharmacyNotificationsScreen extends StatelessWidget {
  const PharmacyNotificationsScreen({super.key});

  void _handleTap(BuildContext context, AppNotification notification) {
    if (!notification.isRead) {
      context.read<NotificationsCubit>().markAsRead(notification.id);
    }
  }

  Future<void> _handleAction(
    BuildContext context,
    AppNotification notification,
  ) async {
    if (!notification.isRead) {
      await context.read<NotificationsCubit>().markAsRead(notification.id);
    }
    if (!context.mounted) return;
    final tab = switch (notification.type) {
      NotificationType.lowStock ||
      NotificationType.outOfStock => PharmacyDashboardTab.inventory,
      NotificationType.newInquiry => PharmacyDashboardTab.inquiries,
      NotificationType.newRating || NotificationType.other => null,
    };
    if (tab != null) Navigator.of(context).pop(tab);
  }

  Future<void> _handleMarkAllAsRead(BuildContext context) async {
    final error = await context.read<NotificationsCubit>().markAllAsRead();
    if (error != null && context.mounted) {
      AppSnackbar.show(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'الإشعارات',
          style: AppTextStyles.screenTitle.copyWith(
            color: AppColors.mainTeal,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            return switch (state) {
              NotificationsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              NotificationsLoadFailure(:final message) => ProfileLoadError(
                message: message,
                onRetry: () => context.read<NotificationsCubit>().load(),
              ),
              NotificationsLoaded() => _buildLoaded(context, state),
            };
          },
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, NotificationsLoaded state) {
    final filtered = state.filteredNotifications;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.unreadCount > 0)
                Center(
                  child: TextButton(
                    onPressed: state.markingAllAsRead
                        ? null
                        : () => _handleMarkAllAsRead(context),
                    child: Text(
                      'تحديد الكل كمقروء',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 8.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    AppFilterChip(
                      label: 'الكل',
                      selected: state.filter == NotificationFilter.all,
                      onTap: () => context
                          .read<NotificationsCubit>()
                          .filterChanged(NotificationFilter.all),
                    ),
                    SizedBox(width: 8.w),
                    AppFilterChip(
                      label: 'غير مقروءة',
                      color: AppColors.primaryTeal,
                      selected: state.filter == NotificationFilter.unread,
                      onTap: () => context
                          .read<NotificationsCubit>()
                          .filterChanged(NotificationFilter.unread),
                    ),
                    SizedBox(width: 8.w),
                    AppFilterChip(
                      label: 'المخزون',
                      color: AppColors.warning,
                      selected: state.filter == NotificationFilter.inventory,
                      onTap: () => context
                          .read<NotificationsCubit>()
                          .filterChanged(NotificationFilter.inventory),
                    ),
                    SizedBox(width: 8.w),
                    AppFilterChip(
                      label: 'الاستفسارات',
                      color: AppColors.mainTeal,
                      selected: state.filter == NotificationFilter.inquiries,
                      onTap: () => context
                          .read<NotificationsCubit>()
                          .filterChanged(NotificationFilter.inquiries),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'لا توجد إشعارات',
                    style: AppTextStyles.cardDescription,
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final notification = filtered[index];
                    return NotificationCard(
                      notification: notification,
                      onTap: () => _handleTap(context, notification),
                      onAction: () => _handleAction(context, notification),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
