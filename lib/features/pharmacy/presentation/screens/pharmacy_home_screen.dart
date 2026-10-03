import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../../../auth/presentation/cubit/logout_cubit.dart';
import '../../../auth/presentation/cubit/logout_state.dart';
import '../../domain/entities/pharmacy_dashboard_stats.dart';
import '../../domain/entities/pharmacy_order.dart';
import '../cubit/pharmacy_dashboard_cubit.dart';
import '../cubit/pharmacy_dashboard_state.dart';
import 'pharmacy_order_details_screen.dart';
import '../helpers/notifications_navigation.dart';
import '../widgets/add_medicines_file_card.dart';
import '../widgets/pharmacy_dashboard_tab_scope.dart';
import '../widgets/pharmacy_home_header.dart';
import '../widgets/pharmacy_orders_section.dart';
import '../widgets/pharmacy_stat_tiles.dart';
import '../widgets/pharmacy_summary_cards.dart';

/// The pharmacy's الرئيسية tab: greeting and address, the figures for its
/// stock, and — once it has any — its orders. A pharmacy with no medicines
/// yet also gets the dashed "add your medicines file" prompt on top.
///
/// Expects a [PharmacyDashboardCubit], a [PharmacyProfileCubit] (for the
/// header) and a [LogoutCubit] above it.
class PharmacyHomeScreen extends StatelessWidget {
  /// The pharmacy's newest orders. There is no orders API yet, so the shell
  /// opens the screen with none and the section stays hidden; this is what
  /// lets the populated state be built and tested now, and have real orders
  /// handed in once an API exists.
  final List<PharmacyOrder> orders;

  const PharmacyHomeScreen({super.key, this.orders = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Every tab of the shell is alive at once, and the other tabs' side
      // menus start the logout — so this is where the app finds out it
      // happened and returns to the account-type screen.
      body: BlocListener<LogoutCubit, LogoutState>(
        listenWhen: (previous, current) =>
            !previous.isLoggedOut && current.isLoggedOut,
        listener: (context, state) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(Routes.accountTypeScreen, (route) => false);
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PharmacyHomeHeader(
                  onNotificationsTap: () => openNotifications(context),
                ),
                SizedBox(height: 23.h),
                BlocBuilder<PharmacyDashboardCubit, PharmacyDashboardState>(
                  builder: (context, state) {
                    return switch (state) {
                      PharmacyDashboardLoading() => Padding(
                        padding: EdgeInsets.only(top: 80.h),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      PharmacyDashboardLoadFailure(:final message) =>
                        ProfileLoadError(
                          message: message,
                          onRetry: () =>
                              context.read<PharmacyDashboardCubit>().load(),
                        ),
                      PharmacyDashboardLoaded(:final stats) => _HomeContent(
                        stats: stats,
                        orders: orders,
                      ),
                    };
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final PharmacyDashboardStats stats;
  final List<PharmacyOrder> orders;

  const _HomeContent({required this.stats, required this.orders});

  void _comingSoon(BuildContext context) => AppSnackbar.show(context, 'قريباً');

  void _goToTab(BuildContext context, PharmacyDashboardTab tab) {
    PharmacyDashboardTabScope.switchToTabOrShowComingSoon(context, tab);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!stats.hasMedicines) ...[
          // Importing a file has no endpoint yet.
          AddMedicinesFileCard(onPickFile: () => _comingSoon(context)),
          SizedBox(height: 16.h),
        ],
        PharmacySummaryCards(
          totalProducts: stats.totalMedicines,
          // The mobile API has no monthly-sales figure yet.
          monthlySales: null,
          onProductsTap: () => _goToTab(context, PharmacyDashboardTab.products),
        ),
        SizedBox(height: 8.h),
        PharmacyStatTiles(
          available: stats.availableCount,
          lowStock: stats.lowStockCount,
          outOfStock: stats.outOfStockCount,
          averageRating: stats.averageRating,
          onRatingsTap: () =>
              Navigator.of(context).pushNamed(Routes.pharmacyRatingsScreen),
        ),
        if (orders.isNotEmpty) ...[
          SizedBox(height: 40.h),
          PharmacyOrdersSection(
            orders: orders,
            onViewAllTap: () => _goToTab(context, PharmacyDashboardTab.orders),
            onOrderTap: (order) => PharmacyOrderDetailsScreen.open(context, order),
          ),
        ],
      ],
    );
  }
}
