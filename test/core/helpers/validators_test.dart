import 'package:daway_app/core/helpers/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.isValidLocalPhone', () {
    test('accepts a valid 10-digit local phone starting with 05', () {
      expect(Validators.isValidLocalPhone('0599123456'), isTrue);
    });

    test('rejects a phone that is too short', () {
      expect(Validators.isValidLocalPhone('05991234'), isFalse);
    });

    test('rejects a phone that does not start with 05', () {
      expect(Validators.isValidLocalPhone('1599123456'), isFalse);
    });

    test('rejects non-digit characters', () {
      expect(Validators.isValidLocalPhone('05991234a6'), isFalse);
    });

    test('rejects an empty string', () {
      expect(Validators.isValidLocalPhone(''), isFalse);
    });
  });
}
