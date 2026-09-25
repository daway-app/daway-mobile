import '../../../../core/helpers/arabic_plural.dart';

/// "متوفر في صيدلية واحدة" / "متوفر في صيدليتين" / "متوفر في 5 صيدليات" /
/// "متوفر في 12 صيدلية" — the availability line of the medicine cards, with
/// the noun agreeing with the count.
String pharmaciesAvailabilityLabel(int pharmaciesCount) {
  final pharmacies = arabicCountedNoun(
    pharmaciesCount,
    singular: 'صيدلية',
    dual: 'صيدليتين',
    plural: 'صيدليات',
    one: 'صيدلية واحدة',
  );
  return 'متوفر في $pharmacies';
}
