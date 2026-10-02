import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/widgets/coming_soon_tab_screen.dart';
import '../cubit/pharmacy_dashboard_cubit.dart';
import '../cubit/pharmacy_inventory_cubit.dart';
import '../cubit/pharmacy_medicines_cubit.dart';
import '../cubit/pharmacy_profile_cubit.dart';
import '../widgets/pharmacy_bottom_nav_bar.dart';
import '../widgets/pharmacy_dashboard_tab_scope.dart';
import '../widgets/pharmacy_side_menu.dart';
import '../../domain/entities/pharmacy_order.dart';
import 'pharmacy_home_screen.dart';
import 'pharmacy_conversations_screen.dart';
import 'pharmacy_inventory_screen.dart';
import 'pharmacy_medicines_screen.dart';
import 'pharmacy_products_screen.dart';
import 'pharmacy_profile_screen.dart';

/// Bottom-nav shell for the logged-in pharmacy area. Each tab keeps its own
/// Scaffold/AppBar/Drawer (see [PharmacySideMenu]'s doc comment) — this
/// shell only owns which tab is selected, a piece of purely local UI state.
///
/// Lands on حسابي (not الرئيسية) since a pharmacy's data is typically
/// already entered via the web/admin side by the time they log in on the
/// app, so surfacing it first lets them verify/complete it right away.
class PharmacyDashboardShellScreen extends StatefulWidget {
  const PharmacyDashboardShellScreen({super.key});

  @override
  State<PharmacyDashboardShellScreen> createState() =>
      _PharmacyDashboardShellScreenState();
}

class _PharmacyDashboardShellScreenState
    extends State<PharmacyDashboardShellScreen> {
  PharmacyDashboardTab _selectedTab = PharmacyDashboardTab.profile;

  // Owned here rather than by the home tab's own provider, so that coming back
  // to الرئيسية can refresh it (see [_selectTab]).
  final PharmacyDashboardCubit _dashboardCubit =
      getIt<PharmacyDashboardCubit>();

  // The products page's list, made the first time the page is opened (which
  // starts its load) rather than at launch, and owned here so that every later
  // visit can refresh it (see [_selectTab]).
  PharmacyMedicinesCubit? _productsCubit;

  @override
  void dispose() {
    _dashboardCubit.close();
    _productsCubit?.close();
    super.dispose();
  }

  // TODO: design preview only — there is no pharmacy orders API yet. Replace
  // with the real orders (and drop this) once the backend delivers.
  static List<PharmacyOrder> _previewOrders() {
    final now = DateTime.now();
    return [
      for (final minutes in const [5, 30])
        PharmacyOrder(
          orderNumber: 'DW-1021',
          createdAt: now.subtract(Duration(minutes: minutes)),
          itemsCount: 2,
          total: 80,
          area: 'غزة - النصر',
        ),
    ];
  }

  void _selectTab(PharmacyDashboardTab tab) {
    if (tab != _selectedTab) {
      switch (tab) {
        // What الرئيسية shows changes whenever medicines or stock are edited on
        // another tab (each of those reloads only its own cubit), so it is
        // fetched again on the way back.
        case PharmacyDashboardTab.home:
          _dashboardCubit.refresh();
        // Likewise the products page: stock is also edited from the inventory
        // and medicines tabs.
        case PharmacyDashboardTab.products:
          final productsCubit = _productsCubit;
          if (productsCubit == null) {
            _productsCubit = getIt<PharmacyMedicinesCubit>();
          } else {
            productsCubit.refresh();
          }
        default:
      }
    }
    setState(() => _selectedTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    // Keyed by tab, and laid out below in the enum's own order, so the two
    // cannot drift apart: a tab left out here fails at the first build.
    final tabs = <PharmacyDashboardTab, Widget>{
      PharmacyDashboardTab.home: BlocProvider.value(
        value: _dashboardCubit,
        child: PharmacyHomeScreen(orders: _previewOrders()),
      ),
      PharmacyDashboardTab.products: switch (_productsCubit) {
        final cubit? => BlocProvider.value(
          value: cubit,
          child: const PharmacyProductsScreen(),
        ),
        null => const SizedBox.shrink(),
      },
      PharmacyDashboardTab.medicines: BlocProvider(
        create: (_) => getIt<PharmacyMedicinesCubit>(),
        child: const PharmacyMedicinesScreen(),
      ),
      // There is no orders API yet, so the tab is a placeholder.
      PharmacyDashboardTab.orders: const ComingSoonTabScreen(
        title: 'الطلبات',
        icon: Icons.shopping_bag_outlined,
        drawer: PharmacySideMenu(),
      ),
      PharmacyDashboardTab.inventory: BlocProvider(
        create: (_) => getIt<PharmacyInventoryCubit>(),
        child: const PharmacyInventoryScreen(),
      ),
      PharmacyDashboardTab.inquiries: const PharmacyConversationsScreen(),
      PharmacyDashboardTab.profile: const PharmacyProfileScreen(),
    };

    // One profile cubit for the whole shell: the home header shows the same
    // name and address the profile tab edits, so a saved change reaches it
    // without a second fetch.
    return BlocProvider(
      create: (_) => getIt<PharmacyProfileCubit>(),
      child: PharmacyDashboardTabScope(
        switchToTab: _selectTab,
        // The system back button does what the products page's own back chip
        // does: return to الرئيسية.
        child: PopScope(
          canPop: _selectedTab != PharmacyDashboardTab.products,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _selectTab(PharmacyDashboardTab.home);
          },
          child: Scaffold(
            body: IndexedStack(
              index: _selectedTab.index,
              children: [
                for (final tab in PharmacyDashboardTab.values) tabs[tab]!,
              ],
            ),
            bottomNavigationBar: PharmacyBottomNavBar(
              selectedTab: _selectedTab,
              onTabSelected: _selectTab,
            ),
          ),
        ),
      ),
    );
  }
}
