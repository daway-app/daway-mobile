import 'package:flutter/widgets.dart';

import '../../../../core/widgets/app_snackbar.dart';

/// The shell's tabs, in the order [PharmacyDashboardShellScreen] builds
/// them — named so call sites (e.g. the side menu) never hand a raw tab
/// index around, which would silently drift out of sync with the shell's
/// list if either side were reordered.
///
/// "الاستفسارات" has no real screen yet — rename freely once it lands.
enum PharmacyDashboardTab { home, medicines, inventory, inquiries, profile }

/// Lets a widget nested anywhere inside a dashboard tab (e.g. the side menu,
/// which is instantiated separately per tab) switch the shell's active tab
/// without the shell having to thread a callback through every screen.
class PharmacyDashboardTabScope extends InheritedWidget {
  final ValueChanged<PharmacyDashboardTab> switchToTab;

  const PharmacyDashboardTabScope({
    super.key,
    required this.switchToTab,
    required super.child,
  });

  static PharmacyDashboardTabScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PharmacyDashboardTabScope>();
  }

  /// Switches to [tab] from anywhere inside the shell, or shows a "قريباً"
  /// snackbar if this widget somehow isn't inside one — shared by every tab
  /// entry point (the side menu, the home screen's stat cards/quick
  /// actions) so that fallback isn't hand-copied at each call site.
  static void switchToTabOrShowComingSoon(
    BuildContext context,
    PharmacyDashboardTab tab,
  ) {
    final scope = maybeOf(context);
    if (scope != null) {
      scope.switchToTab(tab);
    } else {
      AppSnackbar.show(context, 'قريباً');
    }
  }

  @override
  bool updateShouldNotify(PharmacyDashboardTabScope oldWidget) {
    return switchToTab != oldWidget.switchToTab;
  }
}
