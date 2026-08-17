import 'package:flutter/widgets.dart';

/// The shell's tabs, in the order [PatientDashboardShellScreen] builds them —
/// named so call sites (e.g. the side menu) never hand a raw tab index
/// around, which would silently drift out of sync with the shell's list if
/// either side were reordered.
enum PatientDashboardTab { home, profile, appointments, medications }

/// Lets a widget nested anywhere inside a dashboard tab (e.g. the side menu,
/// which is instantiated separately per tab) switch the shell's active tab
/// without the shell having to thread a callback through every screen.
class PatientDashboardTabScope extends InheritedWidget {
  final ValueChanged<PatientDashboardTab> switchToTab;

  const PatientDashboardTabScope({
    super.key,
    required this.switchToTab,
    required super.child,
  });

  static PatientDashboardTabScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PatientDashboardTabScope>();
  }

  @override
  bool updateShouldNotify(PatientDashboardTabScope oldWidget) {
    return switchToTab != oldWidget.switchToTab;
  }
}
