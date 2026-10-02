import '../../domain/entities/medicine_pharmacy_offer.dart';

class MedicinePharmacyOfferModel {
  final int pharmacyId;
  final String pharmacyName;
  final double? distanceKm;
  final double price;
  final int? pharmacyMedicineId;

  const MedicinePharmacyOfferModel({
    required this.pharmacyId,
    required this.pharmacyName,
    this.distanceKm,
    required this.price,
    this.pharmacyMedicineId,
  });

  factory MedicinePharmacyOfferModel.fromJson(Map<String, dynamic> json) {
    return MedicinePharmacyOfferModel(
      pharmacyId: (json['pharmacy_id'] as num?)?.toInt() ?? 0,
      pharmacyName: json['name'] as String? ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      pharmacyMedicineId: (json['pharmacy_medicine_id'] as num?)?.toInt(),
    );
  }

  MedicinePharmacyOffer toEntity() => MedicinePharmacyOffer(
        pharmacyId: pharmacyId,
        pharmacyName: pharmacyName,
        distanceKm: distanceKm,
        price: price,
        pharmacyMedicineId: pharmacyMedicineId,
      );
}
