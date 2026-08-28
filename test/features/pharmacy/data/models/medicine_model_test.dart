import 'package:daway_app/features/pharmacy/data/models/medicine_model.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson parses a pharmacy_medicine with a nested catalog medicine', () {
    final model = MedicineModel.fromJson({
      'id': 1,
      'medicine_id': 5,
      'price': '25.00',
      'quantity': 120,
      'is_available': true,
      'is_low_stock': false,
      'is_out_of_stock': false,
      'medicine': {
        'id': 5,
        'trade_name': 'Panadol',
        'trade_name_ar': 'بانادول',
        'active_ingredient': 'Paracetamol 500mg',
        'image_url': 'https://example.com/panadol.jpg',
      },
    });

    expect(model.id, 1);
    expect(model.medicineId, 5);
    expect(model.name, 'Panadol');
    expect(model.nameAr, 'بانادول');
    expect(model.activeIngredient, 'Paracetamol 500mg');
    expect(model.imageUrl, 'https://example.com/panadol.jpg');
    expect(model.price, 25.0);
    expect(model.quantity, 120);
    expect(model.isAvailable, isTrue);
    expect(model.isLowStock, isFalse);
    expect(model.isOutOfStock, isFalse);
  });

  test('fromJson tolerates a missing nested medicine object without corrupting medicineId', () {
    final model = MedicineModel.fromJson({
      'id': 2,
      'medicine_id': 6,
      'price': 18.5,
      'quantity': 45,
      'is_available': true,
    });

    // Must not fall back to the pharmacy_medicine row's own `id` (2) —
    // that would silently mislabel which catalog medicine this stocks.
    expect(model.medicineId, 6);
    expect(model.name, '');
    expect(model.price, 18.5);
  });

  test('toEntity prefers the server-computed is_low_stock/is_out_of_stock flags', () {
    final low = MedicineModel.fromJson({
      'id': 2,
      'quantity': 500, // would compute as "available" locally — flags win
      'is_low_stock': true,
      'is_out_of_stock': false,
      'price': 18.5,
      'medicine': {'id': 6, 'trade_name': 'Amoxil'},
    }).toEntity();

    expect(low.status, MedicineStatus.low);
  });

  test('toEntity falls back to computing from quantity when flags are absent', () {
    final available = MedicineModel.fromJson({
      'id': 1,
      'quantity': 120,
      'price': 25,
      'medicine': {'id': 5, 'trade_name': 'Panadol'},
    }).toEntity();
    final low = MedicineModel.fromJson({
      'id': 2,
      'quantity': 3,
      'price': 18.5,
      'medicine': {'id': 6, 'trade_name': 'Amoxil'},
    }).toEntity();
    final outOfStock = MedicineModel.fromJson({
      'id': 3,
      'quantity': 0,
      'price': 10,
      'medicine': {'id': 7, 'trade_name': 'Aspirin'},
    }).toEntity();

    expect(available.status, MedicineStatus.available);
    expect(low.status, MedicineStatus.low);
    expect(outOfStock.status, MedicineStatus.outOfStock);
  });
}
