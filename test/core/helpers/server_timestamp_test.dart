import 'package:daway_app/core/helpers/server_timestamp.dart';
import 'package:flutter_test/flutter_test.dart';

// These compare instants (never the local wall clock), so they hold in any
// time zone the tests happen to run in.
void main() {
  final instant = DateTime.utc(2026, 9, 24, 16, 8, 9);

  test('a "Z" timestamp (the API\'s created_at shape) is the same instant, in local time', () {
    final parsed = parseServerTimestamp('2026-09-24T16:08:09.000000Z');

    expect(parsed.isAtSameMomentAs(instant), isTrue);
    expect(parsed.isUtc, isFalse);
  });

  test('a timestamp with no zone is read as UTC, the server clock, not as the device\'s zone', () {
    final parsed = parseServerTimestamp('2026-09-24 16:08:09');

    expect(parsed.isAtSameMomentAs(instant), isTrue);
    expect(parsed.isUtc, isFalse);
  });

  test('an explicit offset is honored', () {
    final parsed = parseServerTimestamp('2026-09-24T19:08:09+03:00');

    expect(parsed.isAtSameMomentAs(instant), isTrue);
  });

  test('the result is local time, so date and time-of-day widgets show the device\'s clock', () {
    final parsed = parseServerTimestamp('2026-09-24T16:08:09Z');

    expect(parsed.hour, instant.toLocal().hour);
    expect(parsed.day, instant.toLocal().day);
  });

  test('anything that is not a date throws a FormatException', () {
    expect(() => parseServerTimestamp('not a date'), throwsFormatException);
  });
}
