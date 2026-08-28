import '../../domain/entities/medicine.dart';

/// Parses a `pharmacy_medicine` record. The descriptive fields (trade name,
/// active ingredient, image) live on the nested `medicine` catalog object,
/// confirmed against a live `GET /pharmacy/medicines` response.
class MedicineModel {
  final int id;
  final int medicineId;
  final String name;
  final String? nameAr;
  final String? activeIngredient;
  final String? imageUrl;
  final double price;
  final int quantity;
  final bool isAvailable;
  final bool? isLowStock;
  final bool? isOutOfStock;

  const MedicineModel({
    required this.id,
    required this.medicineId,
    required this.name,
    this.nameAr,
    this.activeIngredient,
    this.imageUrl,
    required this.price,
    required this.quantity,
    required this.isAvailable,
    this.isLowStock,
    this.isOutOfStock,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    final catalog = json['medicine'] as Map<String, dynamic>? ?? const {};

    return MedicineModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      medicineId: (json['medicine_id'] as num?)?.toInt() ?? (catalog['id'] as num?)?.toInt() ?? 0,
      name: catalog['trade_name'] as String? ?? '',
      nameAr: catalog['trade_name_ar'] as String?,
      activeIngredient: catalog['active_ingredient'] as String?,
      imageUrl: catalog['image_url'] as String?,
      price: _parseDouble(json['price']),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
      isLowStock: json['is_low_stock'] as bool?,
      isOutOfStock: json['is_out_of_stock'] as bool?,
    );
  }

  static double _parseDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Medicine toEntity() => Medicine(
        id: id,
        medicineId: medicineId,
        name: name,
        nameAr: nameAr,
        activeIngredient: activeIngredient,
        imageUrl: imageUrl,
        price: price,
        quantity: quantity,
        isAvailable: isAvailable,
        isLowStock: isLowStock,
        isOutOfStock: isOutOfStock,
      );
}
