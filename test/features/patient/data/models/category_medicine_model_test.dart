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
}
