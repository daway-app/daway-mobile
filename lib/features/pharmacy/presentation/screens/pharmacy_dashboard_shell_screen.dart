import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/widgets/coming_soon_tab_screen.dart';
import '../cubit/pharmacy_dashboard_cubit.dart';
import '../cubit/pharmacy_inventory_cubit.dart';
import '../cubit/pharmacy_medicines_cubit.dart';
import '../cubit/pharmacy_profile_cubit.dart';
import '../widgets/pharmacy_dashboard_tab_scope.dart';
import '../widgets/pharmacy_side_menu.dart';
import 'pharmacy_home_screen.dart';
import 'pharmacy_inventory_screen.dart';
import 'pharmacy_medicines_screen.dart';
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
  State<PharmacyDashboardShellScreen> createState() => _PharmacyDashboardShellScreenState();
}

class _PharmacyDashboardShellScreenState extends State<PharmacyDashboardShellScreen> {
  PharmacyDashboardTab _selectedTab = PharmacyDashboardTab.profile;

  @override
  Widget build(BuildContext context) {
    // Order must match PharmacyDashboardTab's declaration order.
    final tabs = [
      BlocProvider(
        create: (_) => getIt<PharmacyDashboardCubit>(),
        child: const PharmacyHomeScreen(),
      ),
      BlocProvider(
        create: (_) => getIt<PharmacyMedicinesCubit>(),
        child: const PharmacyMedicinesScreen(),
      ),
      BlocProvider(
        create: (_) => getIt<PharmacyInventoryCubit>(),
        child: const PharmacyInventoryScreen(),
      ),
      const ComingSoonTabScreen(
        title: 'الاستفسارات',
        icon: Icons.chat_bubble_outline,
        drawer: PharmacySideMenu(),
      ),
      BlocProvider(
        create: (_) => getIt<PharmacyProfileCubit>(),
        child: const PharmacyProfileScreen(),
      ),
    ];

    return PharmacyDashboardTabScope(
      switchToTab: (tab) => setState(() => _selectedTab = tab),
      child: Scaffold(
        body: IndexedStack(index: _selectedTab.index, children: tabs),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppColors.background,
          currentIndex: _selectedTab.index,
          onTap: (index) => setState(() => _selectedTab = PharmacyDashboardTab.values[index]),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.mainTeal,
          unselectedItemColor: AppColors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.medication_outlined), label: 'الأدوية'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'المخزون'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'الاستفسارات'),
            BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'حسابي'),
          ],
        ),
      ),
    );
  }
}
