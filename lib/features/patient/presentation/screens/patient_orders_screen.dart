import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/filter_tabs_row.dart';
import '../../domain/entities/order.dart';
import '../widgets/order_card.dart';
import '../widgets/patient_sub_screen_header.dart';

/// "طلباتي" — there is no checkout/orders backend yet (no cart, no orders
/// API), so the app opens it with no [orders] (same as [PatientAddressesScreen]
/// has no backend for named addresses). The populated-state UI (status tabs,
/// order cards) is driven by [orders], which is what lets it be tested now and
/// have real data handed in the moment an orders API exists.
class PatientOrdersScreen extends StatefulWidget {
  final List<Order> orders;

  const PatientOrdersScreen({super.key, this.orders = const []});

  @override
  State<PatientOrdersScreen> createState() => _PatientOrdersScreenState();
}

class _PatientOrdersScreenState extends State<PatientOrdersScreen> {
  OrderStatus? _selectedFilter;

  List<Order> get _filteredOrders => _selectedFilter == null
      ? widget.orders
      : widget.orders.where((order) => order.status == _selectedFilter).toList();

  int _countFor(OrderStatus? status) => status == null
      ? widget.orders.length
      : widget.orders.where((order) => order.status == status).length;

  void _browseCategories() {
    Navigator.of(context).pushNamed(Routes.allCategoriesScreen);
  }

  void _viewOrder(Order order) => AppSnackbar.show(context, 'قريباً');

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
              if (widget.orders.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: EmptyStateView(
                    imageAsset: 'assets/images/empty_order.png',
                    title: 'لا يوجد طلبات',
                    subtitle: 'أضف الطلبات حتى تتمكن من تتبعها',
                    actionLabel: 'تصفح الاقسام',
                    onActionTap: _browseCategories,
                    topSpacing: 56,
                  ),
                )
              else ...[
                FilterTabsRow<OrderStatus?>(
                  selected: _selectedFilter,
                  onSelected: (status) => setState(() => _selectedFilter = status),
                  tabs: [
                    FilterTabItem(value: null, label: 'الكل (${_countFor(null)})'),
                    FilterTabItem(
                      value: OrderStatus.completed,
                      label: 'مكتملة (${_countFor(OrderStatus.completed)})',
                    ),
                    FilterTabItem(
                      value: OrderStatus.inProgress,
                      label: 'قيد التنفيذ (${_countFor(OrderStatus.inProgress)})',
                    ),
                    FilterTabItem(
                      value: OrderStatus.cancelled,
                      label: 'ملغاة (${_countFor(OrderStatus.cancelled)})',
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                if (_filteredOrders.isEmpty)
                  // A status with no orders in it: say so under the tabs
                  // instead of leaving them floating above blank space.
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: const EmptyStateView(
                      imageAsset: 'assets/images/empty_order.png',
                      title: 'لا يوجد طلبات',
                      topSpacing: 64,
                    ),
                  )
                else
                  for (final order in _filteredOrders) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: OrderCard(order: order, onViewTap: () => _viewOrder(order)),
                    ),
                    SizedBox(height: 24.h),
                  ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
