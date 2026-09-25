import 'package:daway_app/features/patient/data/models/favorite_medicine_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a full medicine JSON object from the live favorites response shape', () {
    // Captured from GET /patient/favorites/medicines after favoriting Panadol.
    final model = FavoriteMedicineModel.fromJson({
      'id': 2,
      'favoritable_type': 'App\\Models\\Medicine',
      'favoritable_id': 1,
      'medicine_id': 1,
      'trade_name': 'Panadol',
      'trade_name_ar': null,
      'active_ingredient': 'Paracetamol',
      'image_url': null,
      'is_available': true,
      'availability_status': 'available',
      'pharmacies_count': 1,
      'min_price': 60,
      'created_at': null,
    });

    final entity = model.toEntity();

    expect(entity.medicineId, 1);
    expect(entity.tradeName, 'Panadol');
    expect(entity.tradeNameAr, isNull);
    expect(entity.displayName, 'Panadol'); // falls back since trade_name_ar is null
    expect(entity.imageUrl, isNull);
    expect(entity.isAvailable, isTrue);
    expect(entity.pharmaciesCount, 1);
    expect(entity.minPrice, 60);
  });

  test('prefers the Arabic name for displayName when present', () {
    final model = FavoriteMedicineModel.fromJson({
      'medicine_id': 5,
      'trade_name': 'Vitamin C',
      'trade_name_ar': 'فيتامين سي',
      'is_available': 1,
      'pharmacies_count': 3,
    });

    expect(model.toEntity().displayName, 'فيتامين سي');
  });

  test('falls back to nulls/zero for missing optional fields', () {
    final model = FavoriteMedicineModel.fromJson({});

    final entity = model.toEntity();

    expect(entity.medicineId, 0);
    expect(entity.tradeName, '');
    expect(entity.tradeNameAr, isNull);
    expect(entity.imageUrl, isNull);
    expect(entity.isAvailable, isFalse);
    expect(entity.pharmaciesCount, 0);
    expect(entity.minPrice, isNull);
  });
}
