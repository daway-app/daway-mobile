import 'package:daway_app/features/patient/data/models/searched_medicine_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a full medicine JSON object from the live search response shape', () {
    // Captured from GET /medicines/search?q=panadol.
    final model = SearchedMedicineModel.fromJson({
      'id': 1,
      'trade_name': 'Panadol',
      'active_ingredient': 'Paracetamol',
      'description': 'For fever and pain relief.',
      'image_url': null,
      'is_available': 1,
      'available_pharmacies_count': 1,
      'nearest_pharmacy': null,
    });

    final entity = model.toEntity();

    expect(entity.id, 1);
    expect(entity.tradeName, 'Panadol');
    expect(entity.activeIngredient, 'Paracetamol');
    expect(entity.imageUrl, isNull);
    expect(entity.isAvailable, isTrue);
    expect(entity.availablePharmaciesCount, 1);
  });

  test('treats is_available: 0 as unavailable', () {
    final model = SearchedMedicineModel.fromJson({
      'id': 2,
      'trade_name': 'Aspirin',
      'is_available': 0,
      'available_pharmacies_count': 0,
    });

    expect(model.toEntity().isAvailable, isFalse);
  });

  test('falls back to nulls/empty/zero for missing optional fields', () {
    final model = SearchedMedicineModel.fromJson({'id': 4388});

    final entity = model.toEntity();

    expect(entity.id, 4388);
    expect(entity.tradeName, '');
    expect(entity.activeIngredient, isNull);
    expect(entity.imageUrl, isNull);
    expect(entity.isAvailable, isFalse);
    expect(entity.availablePharmaciesCount, 0);
  });
}
