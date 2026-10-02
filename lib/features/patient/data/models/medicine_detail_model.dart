import '../../domain/entities/medicine_detail.dart';

class MedicineDetailModel {
  final int id;
  final String tradeName;
  final String? imageUrl;

  const MedicineDetailModel({
    required this.id,
    required this.tradeName,
    this.imageUrl,
  });

  factory MedicineDetailModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return MedicineDetailModel(
      id: (data['id'] as num?)?.toInt() ?? 0,
      tradeName: data['trade_name'] as String? ?? '',
      imageUrl: data['image_url'] as String?,
    );
  }

  MedicineDetail toEntity() => MedicineDetail(
        id: id,
        tradeName: tradeName,
        imageUrl: imageUrl,
      );
}
