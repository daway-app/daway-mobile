import 'package:flutter/material.dart';

import '../../../../core/routing/routes.dart';
import '../widgets/pharmacy_dashboard_tab_scope.dart';

/// Opens الإشعارات from any of the dashboard tabs' bell icons. The
/// notifications screen is pushed on top of the shell, so an action inside
/// it that should jump to a specific tab pops back with that
/// [PharmacyDashboardTab] as the result — handled here so every bell icon
/// shares the same "switch to that tab, or show 'قريباً' if that somehow
/// isn't possible" behavior instead of re-implementing it per screen.
Future<void> openNotifications(BuildContext context) async {
  final tab =
      await Navigator.of(context).pushNamed(Routes.pharmacyNotificationsScreen)
          as PharmacyDashboardTab?;
  if (tab != null && context.mounted) {
    PharmacyDashboardTabScope.switchToTabOrShowComingSoon(context, tab);
  }
}
