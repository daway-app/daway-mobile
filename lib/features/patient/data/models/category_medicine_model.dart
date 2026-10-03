import '../../domain/entities/category_medicine.dart';

class CategoryMedicineModel {
  final int id;
  final String tradeName;
  final String? genericName;
  final String? dosageForm;
  final int? medicineId;
  final String? imageUrl;
  final int? pharmaciesCount;

  const CategoryMedicineModel({
    required this.id,
    required this.tradeName,
    this.genericName,
    this.dosageForm,
    this.medicineId,
    this.imageUrl,
    this.pharmaciesCount,
  });

  factory CategoryMedicineModel.fromJson(Map<String, dynamic> json) {
    return CategoryMedicineModel(
      id: json['id'] as int,
      tradeName: json['trade_name'] as String? ?? '',
      genericName: json['generic_name'] as String?,
      dosageForm: json['dosage_form'] as String?,
      medicineId: (json['medicine_id'] as num?)?.toInt(),
      imageUrl: (json['image_url'] ?? json['image']) as String?,
      pharmaciesCount: (json['pharmacies_count'] as num?)?.toInt(),
    );
  }

  CategoryMedicine toEntity() => CategoryMedicine(
        id: id,
        tradeName: tradeName,
        genericName: genericName,
        dosageForm: dosageForm,
        medicineId: medicineId,
        imageUrl: imageUrl,
        pharmaciesCount: pharmaciesCount,
      );
}
