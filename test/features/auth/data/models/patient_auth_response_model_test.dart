import 'package:daway_app/features/auth/data/models/patient_auth_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PatientAuthResponseModel.fromJson', () {
    test('parses the token and existing-account flag from a real login response', () {
      final json = {
        'success': true,
        'message': 'Logged in successfully',
        'data': {
          'user': {
            'id': 15,
            'name': 'New User',
            'phone': '0599123456',
            'role': 'patient',
            'is_new': false,
          },
          'token': '6|APXaNniSDREpA8c4yB5l4G4kf2t2c5QO75ykrmyGfb1dcdd7',
        },
      };

      final model = PatientAuthResponseModel.fromJson(json);

      expect(model.token, '6|APXaNniSDREpA8c4yB5l4G4kf2t2c5QO75ykrmyGfb1dcdd7');
      expect(model.isNewAccount, isFalse);
    });

    test('marks the account as new when the user was just created', () {
      final json = {
        'success': true,
        'message': 'Logged in successfully',
        'data': {
          'user': {
            'id': 16,
            'name': 'New User',
            'phone': '0599123457',
            'role': 'patient',
            'is_new': true,
          },
          'token': 'some-token',
        },
      };

      final model = PatientAuthResponseModel.fromJson(json);

      expect(model.isNewAccount, isTrue);
    });
  });
}
