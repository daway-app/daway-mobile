import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/filter_tabs_row.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../../domain/entities/order.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import '../widgets/order_card.dart';
import '../widgets/patient_sub_screen_header.dart';

enum _StatusFilter { completed, inProgress, cancelled }

bool _matches(Order order, _StatusFilter? filter) => switch (filter) {
      null => true,
      _StatusFilter.completed => order.status.isCompleted,
      _StatusFilter.inProgress => order.status.isInProgress,
      _StatusFilter.cancelled => order.status.isCancelled,
    };

/// "طلباتي" — backed by the real `/patient/orders` endpoint.
class PatientOrdersScreen extends StatelessWidget {
  const PatientOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrdersCubit>(),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatefulWidget {
  const _OrdersView();

  @override
  State<_OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<_OrdersView> {
  _StatusFilter? _selectedFilter;

  List<Order> _filtered(List<Order> orders) =>
      orders.where((order) => _matches(order, _selectedFilter)).toList();

  int _countFor(List<Order> orders, _StatusFilter? filter) =>
      orders.where((order) => _matches(order, filter)).length;

  void _browseCategories() {
    Navigator.of(context).pushNamed(Routes.allCategoriesScreen);
  }

  Future<void> _viewOrder(Order order) async {
    final cubit = context.read<OrdersCubit>();
    final cancel = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => _OrderSheet(order: order),
    );
    if (cancel != true) return;
    final error = await cubit.cancel(order);
    if (!mounted) return;
    AppSnackbar.show(context, error ?? 'تم إلغاء الطلب');
  }

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
                  title: 'طلباتي',
                  description: 'تابع طلباتك وراجع سجل مشترياتك',
                ),
              ),
              SizedBox(height: 24.h),
              BlocBuilder<OrdersCubit, OrdersState>(
                builder: (context, state) {
                  return switch (state) {
                    OrdersLoading() => const Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    OrdersLoadFailure(:final message) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: ProfileLoadError(
                          message: message,
                          onRetry: () => context.read<OrdersCubit>().load(),
                        ),
                      ),
                    OrdersLoaded(:final orders) when orders.isEmpty => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: EmptyStateView(
                          imageAsset: 'assets/images/empty_order.png',
                          title: 'لا يوجد طلبات',
                          subtitle: 'أضف الطلبات حتى تتمكن من تتبعها',
                          actionLabel: 'تصفح الاقسام',
                          onActionTap: _browseCategories,
                          topSpacing: 56,
                        ),
                      ),
                    OrdersLoaded(:final orders) => _OrdersList(
                        orders: orders,
                        filtered: _filtered(orders),
                        selectedFilter: _selectedFilter,
                        countFor: (filter) => _countFor(orders, filter),
                        onFilterSelected: (filter) => setState(() => _selectedFilter = filter),
                        onViewOrder: _viewOrder,
                      ),
                  };
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSheet extends StatelessWidget {
  final Order order;

  const _OrderSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'طلب رقم ${order.orderNumber} — ${order.pharmacyName}',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12.h),
            Text(
              'عدد المنتجات: ${order.itemsCount}\nالإجمالي: ${order.price} \$\nالعنوان: ${order.address}',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14.sp, height: 1.6),
            ),
            SizedBox(height: 24.h),
            if (order.status.canCancel)
              AppCustomButton(
                text: 'إلغاء الطلب',
                backgroundColor: AppColors.logoutRed,
                onPressed: () => Navigator.of(context).pop(true),
              ),
          ],
        ),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final List<Order> orders;
  final List<Order> filtered;
  final _StatusFilter? selectedFilter;
  final int Function(_StatusFilter?) countFor;
  final ValueChanged<_StatusFilter?> onFilterSelected;
  final ValueChanged<Order> onViewOrder;

  const _OrdersList({
    required this.orders,
    required this.filtered,
    required this.selectedFilter,
    required this.countFor,
    required this.onFilterSelected,
    required this.onViewOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilterTabsRow<_StatusFilter?>(
          selected: selectedFilter,
          onSelected: onFilterSelected,
          tabs: [
            FilterTabItem(value: null, label: 'الكل (${countFor(null)})'),
            FilterTabItem(
              value: _StatusFilter.completed,
              label: 'مكتملة (${countFor(_StatusFilter.completed)})',
            ),
            FilterTabItem(
              value: _StatusFilter.inProgress,
              label: 'قيد التنفيذ (${countFor(_StatusFilter.inProgress)})',
            ),
            FilterTabItem(
              value: _StatusFilter.cancelled,
              label: 'ملغاة (${countFor(_StatusFilter.cancelled)})',
            ),
          ],
        ),
        SizedBox(height: 24.h),
        if (filtered.isEmpty)
          // A status with no orders in it: say so under the tabs instead of
          // leaving them floating above blank space.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: const EmptyStateView(
              imageAsset: 'assets/images/empty_order.png',
              title: 'لا يوجد طلبات',
              topSpacing: 64,
            ),
          )
        else
          for (final order in filtered) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: OrderCard(order: order, onViewTap: () => onViewOrder(order)),
            ),
            SizedBox(height: 24.h),
          ],
      ],
    );
  }
}
