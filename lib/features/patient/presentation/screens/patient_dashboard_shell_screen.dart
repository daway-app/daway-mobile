import 'package:flutter/material.dart';

import '../../../../core/widgets/coming_soon_tab_screen.dart';
import '../widgets/patient_bottom_nav_bar.dart';
import '../widgets/patient_dashboard_tab_scope.dart';
import '../widgets/patient_side_menu.dart';
import 'patient_account_screen.dart';
import 'patient_home_screen.dart';

/// Bottom-nav shell for the logged-in patient area. Each tab keeps its own
/// Scaffold/AppBar/Drawer (see [PatientSideMenu]'s doc comment) — this shell
/// only owns which tab is selected, a piece of purely local UI state.
class PatientDashboardShellScreen extends StatefulWidget {
  const PatientDashboardShellScreen({super.key});

  @override
  State<PatientDashboardShellScreen> createState() => _PatientDashboardShellScreenState();
}

class _PatientDashboardShellScreenState extends State<PatientDashboardShellScreen> {
  PatientDashboardTab _selectedTab = PatientDashboardTab.home;

  @override
  Widget build(BuildContext context) {
    // Order must match PatientDashboardTab's declaration order.
    final tabs = [
      const PatientHomeScreen(),
      const ComingSoonTabScreen(
        title: 'البحث',
        icon: Icons.search,
        drawer: PatientSideMenu(),
      ),
      const ComingSoonTabScreen(
        title: 'المسح الضوئي',
        icon: Icons.crop_free,
        drawer: PatientSideMenu(),
      ),
      const ComingSoonTabScreen(
        title: 'المراسلات',
        icon: Icons.chat_bubble_outline,
        drawer: PatientSideMenu(),
      ),
      const PatientAccountScreen(),
    ];

    return PatientDashboardTabScope(
      switchToTab: (tab) => setState(() => _selectedTab = tab),
      child: Scaffold(
        body: IndexedStack(index: _selectedTab.index, children: tabs),
        bottomNavigationBar: PatientBottomNavBar(
          selectedTab: _selectedTab,
          onTabSelected: (tab) => setState(() => _selectedTab = tab),
        ),
      ),
    );
  }
}
