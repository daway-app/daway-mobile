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

  group('Validators.isValidPassword', () {
    test('accepts a password of the minimum length', () {
      expect(Validators.isValidPassword('12345678'), isTrue);
    });

    test('accepts a longer one', () {
      expect(Validators.isValidPassword('a much longer password'), isTrue);
    });

    test('rejects one character short of the minimum', () {
      expect(Validators.isValidPassword('1234567'), isFalse);
    });

    test('rejects an empty string', () {
      expect(Validators.isValidPassword(''), isFalse);
    });

    test('the minimum is 8, as the pharmacy sign-up asks', () {
      expect(Validators.minPasswordLength, 8);
    });
  });
}
