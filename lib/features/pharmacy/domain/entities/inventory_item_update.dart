/// One row of a `POST /pharmacy/inventory/bulk` request — the new quantity
/// and availability for a single `pharmacy_medicine` record.
class InventoryItemUpdate {
  final int pharmacyMedicineId;
  final int quantity;
  final bool isAvailable;

  const InventoryItemUpdate({
    required this.pharmacyMedicineId,
    required this.quantity,
    required this.isAvailable,
  });

  @override
  bool operator ==(Object other) =>
      other is InventoryItemUpdate &&
      other.pharmacyMedicineId == pharmacyMedicineId &&
      other.quantity == quantity &&
      other.isAvailable == isAvailable;

  @override
  int get hashCode => Object.hash(pharmacyMedicineId, quantity, isAvailable);
}
