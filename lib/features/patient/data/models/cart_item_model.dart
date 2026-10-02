import '../../domain/entities/cart_item.dart';

class CartItemModel {
  final int id;
  final int pharmacyId;
  final String pharmacyName;
  final String medicineName;
  final double price;
  final int quantity;

  const CartItemModel({
    required this.id,
    required this.pharmacyId,
    required this.pharmacyName,
    required this.medicineName,
    required this.price,
    required this.quantity,
  });

  /// The line's medicine can come from either the general catalog
  /// (`medicine`) or the MOH catalog (`moh_medicine`) depending on which one
  /// the pharmacy stocked it from — exactly one of the two is non-null.
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final medicine = json['medicine'] as Map<String, dynamic>?;
    final mohMedicine = json['moh_medicine'] as Map<String, dynamic>?;
    final name = medicine?['trade_name'] as String? ??
        mohMedicine?['trade_name'] as String? ??
        '';

    return CartItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      pharmacyId: (json['pharmacy_id'] as num?)?.toInt() ?? 0,
      pharmacyName: json['pharmacy_name'] as String? ?? '',
      medicineName: name,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  CartItem toEntity() => CartItem(
        id: id,
        pharmacyId: pharmacyId,
        pharmacyName: pharmacyName,
        medicineName: medicineName,
        price: price,
        quantity: quantity,
      );
}
