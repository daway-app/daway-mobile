/// Parses a timestamp sent by the backend into the device's local time.
///
/// The backend runs in UTC and sends ISO 8601 with a "Z"
/// ("2026-09-24T16:08:09.000000Z" — verified live against the HTTP `Date`
/// header). A value with no zone at all ("2026-08-22 16:32:25", the shape some
/// older payloads use) is UTC as well, since it comes from the same server
/// clock. Left as a UTC [DateTime], a timestamp would be compared and printed
/// as if it were local time, which is off by the device's UTC offset.
///
/// Throws a [FormatException] on anything that is not a date, like
/// [DateTime.parse].
DateTime parseServerTimestamp(String raw) {
  final parsed = DateTime.parse(raw);
  // A zone ("Z" or an offset) makes DateTime.parse return a UTC value; with
  // none it silently assumes the device's own zone, so read it as UTC instead.
  if (parsed.isUtc) return parsed.toLocal();
  return DateTime.parse('${raw}Z').toLocal();
}
