import 'package:daway_app/core/helpers/arabic_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('matches regardless of hamza, ta marbuta and ya spelling', () {
    expect(arabicContains('صيدلية الأمل', 'صيدلية الامل'), isTrue);
    expect(arabicContains('صيدلية الأمل', 'الامل'), isTrue);
    expect(arabicContains('صيدلية', 'صيدليه'), isTrue);
    expect(arabicContains('مستشفى', 'مستشفي'), isTrue);
  });

  test('ignores diacritics and Latin case, and still rejects non-matches', () {
    expect(arabicContains('الأَمَل', 'الامل'), isTrue);
    expect(arabicContains('Panadol', 'pana'), isTrue);
    expect(arabicContains('صيدلية الأمل', 'الشفاء'), isFalse);
  });
}
