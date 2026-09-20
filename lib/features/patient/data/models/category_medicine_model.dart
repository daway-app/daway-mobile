import '../../domain/entities/category_medicine.dart';

class CategoryMedicineModel {
  final int id;
  final String tradeName;
  final String? genericName;
  final String? dosageForm;

  const CategoryMedicineModel({
    required this.id,
    required this.tradeName,
    this.genericName,
    this.dosageForm,
  });

  factory CategoryMedicineModel.fromJson(Map<String, dynamic> json) {
    return CategoryMedicineModel(
      id: json['id'] as int,
      tradeName: json['trade_name'] as String? ?? '',
      genericName: json['generic_name'] as String?,
      dosageForm: json['dosage_form'] as String?,
    );
  }

  CategoryMedicine toEntity() => CategoryMedicine(
        id: id,
        tradeName: tradeName,
        genericName: genericName,
        dosageForm: dosageForm,
      );
}
