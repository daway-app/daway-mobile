import 'package:daway_app/features/patient/data/models/cart_item_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a cart line whose medicine came from the general catalog', () {
    final model = CartItemModel.fromJson({
      'id': 7,
      'pharmacy_id': 11,
      'pharmacy_name': 'صيدلية النور',
      'pharmacy_medicine_id': 3,
      'medicine': {'id': 1, 'trade_name': 'Panadol', 'active_ingredient': 'Paracetamol'},
      'moh_medicine': null,
      'quantity': 2,
      'price': 18.0,
      'total': 36.0,
    });

    final entity = model.toEntity();

    expect(entity.id, 7);
    expect(entity.pharmacyId, 11);
    expect(entity.pharmacyName, 'صيدلية النور');
    expect(entity.medicineName, 'Panadol');
    expect(entity.price, 18.0);
    expect(entity.quantity, 2);
    expect(entity.lineTotal, 36.0);
  });

  test('falls back to moh_medicine\'s name when medicine is null', () {
    final model = CartItemModel.fromJson({
      'id': 7,
      'pharmacy_id': 11,
      'pharmacy_name': 'صيدلية النور',
      'medicine': null,
      'moh_medicine': {'id': 5, 'trade_name': 'Adol'},
      'quantity': 1,
      'price': 10.0,
    });

    expect(model.toEntity().medicineName, 'Adol');
  });

  test('falls back to nulls/zero/empty for missing fields', () {
    final entity = CartItemModel.fromJson({}).toEntity();

    expect(entity.id, 0);
    expect(entity.pharmacyId, 0);
    expect(entity.pharmacyName, '');
    expect(entity.medicineName, '');
    expect(entity.price, 0);
    expect(entity.quantity, 1);
  });
}
