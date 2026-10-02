import 'package:daway_app/features/patient/data/models/nearby_pharmacy_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a pharmacy row from GET /pharmacies', () {
    final model = NearbyPharmacyModel.fromJson({
      'id': 1,
      'pharmacy_name': 'صيدلية الأمل',
      'address': 'غزة، شارع الوحدة',
      'latitude': 31.5016,
      'longitude': 34.4668,
      'phone_number': '+970591234567',
      'logo': null,
      'is_open_now': true,
    });

    final entity = model.toEntity();

    expect(entity.id, 1);
    expect(entity.name, 'صيدلية الأمل');
    expect(entity.address, 'غزة، شارع الوحدة');
    expect(entity.latitude, 31.5016);
    expect(entity.longitude, 34.4668);
    expect(entity.phoneNumber, '+970591234567');
    expect(entity.isOpenNow, isTrue);
    expect(entity.distanceKm, isNull);
  });

  test('is_open_now sent as integer 1 (not just JSON true) still parses as open', () {
    final model = NearbyPharmacyModel.fromJson({'id': 1, 'is_open_now': 1});

    expect(model.toEntity().isOpenNow, isTrue);
  });

  test('is_open_now sent as integer 0 parses as closed', () {
    final model = NearbyPharmacyModel.fromJson({'id': 1, 'is_open_now': 0});

    expect(model.toEntity().isOpenNow, isFalse);
  });

  test('falls back to nulls/zero/false for missing optional fields', () {
    final model = NearbyPharmacyModel.fromJson({});

    final entity = model.toEntity();

    expect(entity.id, 0);
    expect(entity.name, '');
    expect(entity.address, isNull);
    expect(entity.isOpenNow, isFalse);
  });
}
