import 'package:daway_app/features/pharmacy/data/models/medicine_catalog_item_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Real GET /pharmacy/medicines/search?q=pan item, captured from a live
  // Postman response — the field is `sub`, not `active_ingredient`.
  test('fromJson parses a real search result item', () {
    final model = MedicineCatalogItemModel.fromJson({
      'type': 'medicine',
      'id': 11,
      'name': 'PANADOL TABLET',
      'sub': 'PANADOL TABLET',
    });

    expect(model.id, 11);
    expect(model.name, 'PANADOL TABLET');
    expect(model.activeIngredient, 'PANADOL TABLET');
    expect(model.type, 'medicine');
  });

  // Real GET /pharmacy/medicines/search?q=the item, from data.moh_catalog.
  test('fromJson parses a real Ministry of Health catalog item', () {
    final model = MedicineCatalogItemModel.fromJson({
      'type': 'moh',
      'id': 3,
      'name': 'DR. MANAR ALARAJ NOURSHING & STRENGTHENING ORGANIC HAIR OIL',
      'sub': 'Dr. Manar Alaraj Cosmetics Factory/Palestine',
      'official_price': null,
    });

    expect(model.id, 3);
    expect(model.type, 'moh');
    expect(model.activeIngredient, 'Dr. Manar Alaraj Cosmetics Factory/Palestine');
  });

  test('fromJson tolerates a missing sub/image_url', () {
    final model = MedicineCatalogItemModel.fromJson({'id': 5, 'name': 'Amoxil'});

    expect(model.activeIngredient, isNull);
    expect(model.imageUrl, isNull);
    expect(model.type, isNull);
  });
}
