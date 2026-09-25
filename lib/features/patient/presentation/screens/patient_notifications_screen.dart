import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/filter_tabs_row.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../../domain/entities/patient_notification.dart';
import '../cubit/patient_notifications_cubit.dart';
import '../cubit/patient_notifications_state.dart';
import '../helpers/patient_notification_display.dart';
import '../widgets/notification_item.dart';
import '../widgets/patient_sub_screen_header.dart';

/// "الإشعارات" — backed by the real `GET /notifications` endpoint. Expects a
/// [PatientNotificationsCubit] to already be provided above it (see
/// [PatientAccountScreen]'s `_openNotifications`).
///
/// The design's "الطلبات"/"العروض" tabs are for notification types the
/// backend doesn't emit yet (no orders, no offers), so they read (0) for now
/// and only "النظام" filters anything; the per-item dismiss "X" has no
/// backend either (the API can mark notifications read, not delete them).
class PatientNotificationsScreen extends StatefulWidget {
  const PatientNotificationsScreen({super.key});

  @override
  State<PatientNotificationsScreen> createState() => _PatientNotificationsScreenState();
}

class _PatientNotificationsScreenState extends State<PatientNotificationsScreen> {
  PatientNotificationTab _selectedTab = PatientNotificationTab.all;

  int _countFor(List<PatientNotification> all, PatientNotificationTab tab) {
    return tab == PatientNotificationTab.all
        ? all.length
        : all.where((n) => tabFor(n.type) == tab).length;
  }

  List<PatientNotification> _visible(List<PatientNotification> all) {
    return _selectedTab == PatientNotificationTab.all
        ? all
        : all.where((n) => tabFor(n.type) == _selectedTab).toList();
  }

  void _dismiss() => AppSnackbar.show(context, 'قريباً');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: const PatientSubScreenHeader(
                  title: 'الإشعارات',
                  description: 'تابع طلباتك وراجع سجل مشترياتك',
                ),
              ),
              SizedBox(height: 24.h),
              BlocBuilder<PatientNotificationsCubit, PatientNotificationsState>(
                builder: (context, state) {
                  return switch (state) {
                    PatientNotificationsLoading() => Padding(
                        padding: EdgeInsets.only(top: 48.h),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    PatientNotificationsLoadFailure(:final message) => ProfileLoadError(
                        message: message,
                        onRetry: () => context.read<PatientNotificationsCubit>().load(),
                      ),
                    PatientNotificationsLoaded(:final notifications) when notifications.isEmpty =>
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: const _EmptyNotifications(topSpacing: 88),
                      ),
                    PatientNotificationsLoaded(:final notifications) =>
                      _buildList(notifications),
                  };
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<PatientNotification> all) {
    final visible = _visible(all);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilterTabsRow<PatientNotificationTab>(
          selected: _selectedTab,
          onSelected: (tab) => setState(() => _selectedTab = tab),
          tabs: [
            FilterTabItem(
              value: PatientNotificationTab.all,
              label: 'الكل (${_countFor(all, PatientNotificationTab.all)})',
            ),
            FilterTabItem(
              value: PatientNotificationTab.orders,
              label: 'الطلبات (${_countFor(all, PatientNotificationTab.orders)})',
            ),
            FilterTabItem(
              value: PatientNotificationTab.offers,
              label: 'العروض (${_countFor(all, PatientNotificationTab.offers)})',
            ),
            FilterTabItem(
              value: PatientNotificationTab.system,
              label: 'النظام (${_countFor(all, PatientNotificationTab.system)})',
            ),
          ],
        ),
        SizedBox(height: 24.h),
        if (visible.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: const _EmptyNotifications(topSpacing: 64),
          )
        else
          for (final notification in visible)
            NotificationItem(notification: notification, onDismissTap: _dismiss),
      ],
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  final double topSpacing;

  const _EmptyNotifications({required this.topSpacing});

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      imageAsset: 'assets/images/empty_notifications.png',
      title: 'لا يوجد إشعارات',
      topSpacing: topSpacing,
    );
  }
}
