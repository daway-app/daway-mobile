import 'package:daway_app/features/patient/data/models/medicine_pharmacy_offer_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a pharmacy row from GET /medicines/{id}/pharmacies', () {
    final model = MedicinePharmacyOfferModel.fromJson({
      'pharmacy_id': 11,
      'name': 'صيدلية الأمل',
      'price': 18,
      'quantity': 40,
      'availability_status': 'available',
      'distance_km': 1.2,
      'phone': '+970591234567',
    });

    final entity = model.toEntity();

    expect(entity.pharmacyId, 11);
    expect(entity.pharmacyName, 'صيدلية الأمل');
    expect(entity.price, 18);
    expect(entity.distanceKm, 1.2);
    // No logo/photo field on this endpoint (see the entity's doc comment).
    expect(entity.imageUrl, isNull);
  });

  test('a missing distance_km (no location sent) leaves it null rather than 0', () {
    final model = MedicinePharmacyOfferModel.fromJson({
      'pharmacy_id': 12,
      'name': 'صيدلية الشفاء',
      'price': 20,
    });

    expect(model.toEntity().distanceKm, isNull);
  });

  test('falls back to nulls/zero for missing optional fields', () {
    final model = MedicinePharmacyOfferModel.fromJson({});

    final entity = model.toEntity();

    expect(entity.pharmacyId, 0);
    expect(entity.pharmacyName, '');
    expect(entity.price, 0);
    expect(entity.distanceKm, isNull);
  });
}
