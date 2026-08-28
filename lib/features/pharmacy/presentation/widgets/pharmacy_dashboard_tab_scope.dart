import 'package:flutter/widgets.dart';

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
    return context.dependOnInheritedWidgetOfExactType<PharmacyDashboardTabScope>();
  }

  @override
  bool updateShouldNotify(PharmacyDashboardTabScope oldWidget) {
    return switchToTab != oldWidget.switchToTab;
  }
}
