import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('copyWithQuantity', () {
    const medicine = Medicine(
      id: 1,
      medicineId: 5,
      name: 'Panadol',
      nameAr: 'بانادول',
      activeIngredient: 'Paracetamol',
      imageUrl: 'https://example.com/panadol.jpg',
      price: 25,
      quantity: 3,
      isAvailable: false,
      isLowStock: true,
      isOutOfStock: false,
    );

    test('changes the quantity and keeps everything else', () {
      final changed = medicine.copyWithQuantity(40);

      expect(changed.quantity, 40);
      expect(changed.id, 1);
      expect(changed.medicineId, 5);
      expect(changed.name, 'Panadol');
      expect(changed.nameAr, 'بانادول');
      expect(changed.activeIngredient, 'Paracetamol');
      expect(changed.imageUrl, 'https://example.com/panadol.jpg');
      expect(changed.price, 25);
      expect(changed.isAvailable, isFalse);
    });

    test('drops the server flags, which described the old quantity', () {
      expect(medicine.status, MedicineStatus.low);

      expect(medicine.copyWithQuantity(40).status, MedicineStatus.available);
      expect(medicine.copyWithQuantity(10).status, MedicineStatus.low);
      expect(medicine.copyWithQuantity(0).status, MedicineStatus.outOfStock);
    });
  });
}
