abstract class AppConstants {
  /// Map center shown before the user has picked (or been located to) a
  /// point — Gaza City, matching the sample address in the API docs.
  static const double defaultMapLatitude = 31.5017;
  static const double defaultMapLongitude = 34.4668;

  /// Palestinian/Israeli new shekel — this app's only market (see the map
  /// center above), so every displayed price uses this, not a Gulf riyal.
  static const String currencySuffix = '₪';
}
