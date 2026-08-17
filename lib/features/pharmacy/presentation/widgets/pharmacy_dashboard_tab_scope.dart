import 'package:flutter/widgets.dart';

/// The shell's tabs, in the order [PharmacyDashboardShellScreen] builds
/// them — named so call sites (e.g. the side menu) never hand a raw tab
/// index around, which would silently drift out of sync with the shell's
/// list if either side were reordered.
///
/// Placeholder names ("الطلبات"/"المخزون") for the two tabs with no real
/// screen yet — rename freely once the real features land.
enum PharmacyDashboardTab { home, profile, orders, inventory }

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
    return context.dependOnInheritedWidgetOfExactType<PharmacyDashboardTabScope>();
  }

  @override
  bool updateShouldNotify(PharmacyDashboardTabScope oldWidget) {
    return switchToTab != oldWidget.switchToTab;
  }
}
