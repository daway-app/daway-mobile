/// One pharmacy stocking a medicine, as a row of
/// `GET /medicines/{id}/pharmacies` returns it.
class MedicinePharmacyOffer {
  final int pharmacyId;
  final String pharmacyName;

  /// Not part of this endpoint's documented response (only `GET /pharmacies`
  /// has a `logo`) — always null today, so the card shows a placeholder.
  final String? imageUrl;
  final double? distanceKm;
  final double price;

  /// The id `POST /patient/cart/items` needs. No public endpoint returns it
  /// yet (probed 2026-09-30), so it is null until the backend adds
  /// `pharmacy_medicine_id` to this endpoint's rows.
  final int? pharmacyMedicineId;

  const MedicinePharmacyOffer({
    required this.pharmacyId,
    required this.pharmacyName,
    this.imageUrl,
    this.distanceKm,
    required this.price,
    this.pharmacyMedicineId,
  });
}
