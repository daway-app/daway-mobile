import 'package:daway_app/features/patient/data/models/category_medicine_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a full medicine JSON object', () {
    final model = CategoryMedicineModel.fromJson({
      'id': 2125,
      'trade_name': 'A TO Z EFFERVESCENT TABLET',
      'generic_name': 'Multivitamin',
      'dosage_form': 'Effervescent tablet.',
    });

    final entity = model.toEntity();

    expect(entity.id, 2125);
    expect(entity.tradeName, 'A TO Z EFFERVESCENT TABLET');
    expect(entity.genericName, 'Multivitamin');
    expect(entity.dosageForm, 'Effervescent tablet.');
  });

  test('falls back to nulls/empty string for missing optional fields', () {
    final model = CategoryMedicineModel.fromJson({'id': 4388});

    final entity = model.toEntity();

    expect(entity.id, 4388);
    expect(entity.tradeName, '');
    expect(entity.genericName, isNull);
    expect(entity.dosageForm, isNull);
  });

  test('reads the pharmacy medicine id and the image when the backend sends them', () {
    final model = CategoryMedicineModel.fromJson({
      'id': 15706,
      'trade_name': 'ACAMOL 500MG TAB 20 TAB',
      'generic_name': 'Paracetamol',
      'medicine_id': 18,
      'image_url': 'https://example.com/a.jpg',
    });

    expect(model.id, 15706);
    expect(model.medicineId, 18);
    expect(model.imageUrl, 'https://example.com/a.jpg');
  });

  test('medicine id and image are null when absent', () {
    final model = CategoryMedicineModel.fromJson({'id': 1, 'trade_name': 'X'});

    expect(model.medicineId, isNull);
    expect(model.imageUrl, isNull);
  });

  test('reads the number of pharmacies stocking it', () {
    final model = CategoryMedicineModel.fromJson({
      'id': 15706,
      'trade_name': 'ACAMOL',
      'medicine_id': 18,
      'pharmacies_count': 2,
    });

    expect(model.pharmaciesCount, 2);
    expect(CategoryMedicineModel.fromJson({'id': 1, 'trade_name': 'X'}).pharmaciesCount, isNull);
  });
}
