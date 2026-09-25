import 'package:daway_app/core/helpers/arabic_plural.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String pharmacies(int count) => arabicCountedNoun(
        count,
        singular: 'صيدلية',
        dual: 'صيدليتين',
        plural: 'صيدليات',
      );

  test('1 is the singular alone and 2 is the dual alone', () {
    expect(pharmacies(1), 'صيدلية');
    expect(pharmacies(2), 'صيدليتين');
  });

  test('3 to 10 take the number and the plural', () {
    expect(pharmacies(3), '3 صيدليات');
    expect(pharmacies(10), '10 صيدليات');
  });

  test('11 and more take the number and the singular', () {
    expect(pharmacies(11), '11 صيدلية');
    expect(pharmacies(250), '250 صيدلية');
  });

  test('zero also takes the number and the singular', () {
    expect(pharmacies(0), '0 صيدلية');
  });

  test('a fuller phrase can replace the bare singular for exactly one', () {
    String label(int count) => arabicCountedNoun(
          count,
          singular: 'صيدلية',
          dual: 'صيدليتين',
          plural: 'صيدليات',
          one: 'صيدلية واحدة',
        );

    expect(label(1), 'صيدلية واحدة');
    expect(label(2), 'صيدليتين'); // only the count of one is affected
    expect(label(5), '5 صيدليات');
  });
}
