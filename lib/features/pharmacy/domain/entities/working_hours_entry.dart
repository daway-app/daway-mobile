enum WeekDay { sat, sun, mon, tue, wed, thu, fri }

/// A single day's opening hours — [open]/[close] are both null when the
/// pharmacy is closed that day.
class WorkingHoursEntry {
  final WeekDay day;
  final String? open;
  final String? close;

  const WorkingHoursEntry({required this.day, this.open, this.close});

  bool get isOpen => open != null && close != null;
}
