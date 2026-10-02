import 'package:daway_app/core/helpers/age_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 9, 30);

  test('counts whole years, before and after the birthday', () {
    expect(ageFromBirthDate('2005-08-15', now: today), 21);
    expect(ageFromBirthDate('2005-10-01', now: today), 20);
    expect(ageFromBirthDate('2005-09-30', now: today), 21);
  });

  test('returns null for an unparseable date and never goes negative', () {
    expect(ageFromBirthDate('not-a-date', now: today), isNull);
    expect(ageFromBirthDate('2030-01-01', now: today), 0);
  });
}
