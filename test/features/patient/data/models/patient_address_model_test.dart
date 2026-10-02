import 'package:daway_app/features/patient/data/models/patient_address_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses an address row from GET/POST /patient/addresses', () {
    final model = PatientAddressModel.fromJson({
      'id': 1,
      'label': 'المنزل',
      'recipient_name': 'مريض تجريبي',
      'phone': '0599112233',
      'address': 'غزة - حي الرمال',
      'latitude': 31.5,
      'longitude': 34.47,
      'is_default': true,
    });

    final entity = model.toEntity();

    expect(entity.id, 1);
    expect(entity.label, 'المنزل');
    expect(entity.recipientName, 'مريض تجريبي');
    expect(entity.phone, '0599112233');
    expect(entity.address, 'غزة - حي الرمال');
    expect(entity.latitude, 31.5);
    expect(entity.longitude, 34.47);
    expect(entity.isDefault, isTrue);
  });

  test('falls back to nulls/zero/empty/false for missing fields', () {
    final entity = PatientAddressModel.fromJson({}).toEntity();

    expect(entity.id, 0);
    expect(entity.label, '');
    expect(entity.recipientName, '');
    expect(entity.phone, '');
    expect(entity.address, '');
    expect(entity.latitude, 0);
    expect(entity.longitude, 0);
    expect(entity.isDefault, isFalse);
  });
}
