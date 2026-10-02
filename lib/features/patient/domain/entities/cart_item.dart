/// One line in the patient's cart, as returned by the real `/patient/cart`
/// backend. [id] is the server's cart-line id (used to update/delete this
/// line), not a locally-synthesized key — the backend now owns the cart
/// (merging duplicate `pharmacy_medicine_id` adds server-side), so nothing
/// here is persisted on-device anymore.
class CartItem {
  final int id;
  final int pharmacyId;
  final String pharmacyName;
  final String medicineName;
  final String? medicineImageUrl;
  final double price;
  final int quantity;

  const CartItem({
    required this.id,
    required this.pharmacyId,
    required this.pharmacyName,
    required this.medicineName,
    this.medicineImageUrl,
    required this.price,
    required this.quantity,
  });

  double get lineTotal => price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        id: id,
        pharmacyId: pharmacyId,
        pharmacyName: pharmacyName,
        medicineName: medicineName,
        medicineImageUrl: medicineImageUrl,
        price: price,
        quantity: quantity ?? this.quantity,
      );
}
