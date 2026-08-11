import 'package:daway_app/features/auth/data/models/pharmacy_auth_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PharmacyAuthResponseModel.fromJson', () {
    test('parses the token from a real login response', () {
      final json = {
        'success': true,
        'message': 'Logged in successfully',
        'data': {
          'pharmacy': {'id': 'PH-1234', 'name': 'صيدلية الشفاء'},
          'token': '6|APXaNniSDREpA8c4yB5l4G4kf2t2c5QO75ykrmyGfb1dcdd7',
        },
      };

      final model = PharmacyAuthResponseModel.fromJson(json);

      expect(model.token, '6|APXaNniSDREpA8c4yB5l4G4kf2t2c5QO75ykrmyGfb1dcdd7');
    });
  });
}
