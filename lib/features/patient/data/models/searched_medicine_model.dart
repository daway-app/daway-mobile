import '../../domain/entities/searched_medicine.dart';

class SearchedMedicineModel {
  final int id;
  final String tradeName;
  final String? activeIngredient;
  final String? imageUrl;
  final bool isAvailable;
  final int availablePharmaciesCount;

  const SearchedMedicineModel({
    required this.id,
    required this.tradeName,
    this.activeIngredient,
    this.imageUrl,
    required this.isAvailable,
    required this.availablePharmaciesCount,
  });

  factory SearchedMedicineModel.fromJson(Map<String, dynamic> json) {
    return SearchedMedicineModel(
      id: json['id'] as int,
      tradeName: json['trade_name'] as String? ?? '',
      activeIngredient: json['active_ingredient'] as String?,
      imageUrl: json['image_url'] as String?,
      // The live API serializes this as an int (0/1), not a JSON boolean.
      isAvailable: json['is_available'] == true || json['is_available'] == 1,
      availablePharmaciesCount:
          (json['available_pharmacies_count'] as num?)?.toInt() ?? 0,
    );
  }

  SearchedMedicine toEntity() => SearchedMedicine(
        id: id,
        tradeName: tradeName,
        activeIngredient: activeIngredient,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
        availablePharmaciesCount: availablePharmaciesCount,
      );
}
