import 'package:daway_app/core/helpers/phone_mask.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('maskLocalPhone', () {
    test('keeps the country code and the last two digits', () {
      expect(maskLocalPhone('0591234529'), '+970 XXX XXX X29');
    });

    test('is the same shape for any number', () {
      expect(maskLocalPhone('0599000001'), '+970 XXX XXX X01');
    });

    test('hides every other digit', () {
      final masked = maskLocalPhone('0591234529');

      expect(masked.contains('591'), isFalse);
      expect(masked.contains('234'), isFalse);
      expect(RegExp('[0-9]').allMatches(masked).length, 3 + 2); // 970 and the last two
    });

    test('does not fail on a number shorter than two digits', () {
      expect(maskLocalPhone(''), '+970 XXX XXX X');
      expect(maskLocalPhone('5'), '+970 XXX XXX X5');
    });
  });
}
