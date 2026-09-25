import '../../domain/entities/favorite_medicine.dart';

class FavoriteMedicineModel {
  final int medicineId;
  final String tradeName;
  final String? tradeNameAr;
  final String? imageUrl;
  final bool isAvailable;
  final int pharmaciesCount;
  final double? minPrice;

  const FavoriteMedicineModel({
    required this.medicineId,
    required this.tradeName,
    this.tradeNameAr,
    this.imageUrl,
    required this.isAvailable,
    required this.pharmaciesCount,
    this.minPrice,
  });

  factory FavoriteMedicineModel.fromJson(Map<String, dynamic> json) {
    return FavoriteMedicineModel(
      medicineId: (json['medicine_id'] as num?)?.toInt() ?? 0,
      tradeName: json['trade_name'] as String? ?? '',
      tradeNameAr: json['trade_name_ar'] as String?,
      imageUrl: json['image_url'] as String?,
      // Seen as both a JSON boolean and a 0/1 integer across endpoints.
      isAvailable: json['is_available'] == true || json['is_available'] == 1,
      pharmaciesCount: (json['pharmacies_count'] as num?)?.toInt() ?? 0,
      minPrice: (json['min_price'] as num?)?.toDouble(),
    );
  }

  FavoriteMedicine toEntity() => FavoriteMedicine(
        medicineId: medicineId,
        tradeName: tradeName,
        tradeNameAr: tradeNameAr,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
        pharmaciesCount: pharmaciesCount,
        minPrice: minPrice,
      );
}
