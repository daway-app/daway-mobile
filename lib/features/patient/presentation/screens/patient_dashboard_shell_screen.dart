import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/widgets/coming_soon_tab_screen.dart';
import '../cubit/patient_profile_cubit.dart';
import '../widgets/patient_dashboard_tab_scope.dart';
import '../widgets/patient_side_menu.dart';
import 'patient_home_screen.dart';
import 'patient_profile_screen.dart';

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
      BlocProvider(
        create: (_) => getIt<PatientProfileCubit>(),
        child: const PatientProfileScreen(),
      ),
      const ComingSoonTabScreen(
        title: 'مواعيدي',
        icon: Icons.calendar_month_outlined,
        drawer: PatientSideMenu(),
      ),
      const ComingSoonTabScreen(
        title: 'أدويتي',
        icon: Icons.medication_outlined,
        drawer: PatientSideMenu(),
      ),
    ];

    return PatientDashboardTabScope(
      switchToTab: (tab) => setState(() => _selectedTab = tab),
      child: Scaffold(
        body: IndexedStack(index: _selectedTab.index, children: tabs),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTab.index,
          onTap: (index) => setState(() => _selectedTab = PatientDashboardTab.values[index]),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.mainTeal,
          unselectedItemColor: AppColors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'حسابي'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              label: 'مواعيدي',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.medication_outlined), label: 'أدويتي'),
          ],
        ),
      ),
    );
  }
}
