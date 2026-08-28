/// Stock status derived from a quantity vs the backend's fixed low-stock
/// threshold — mirrors the low_stock/out_of_stock notifications the backend
/// triggers. Shared so both [Medicine.status] and screens computing a status
/// ahead of having a full [Medicine] (e.g. a live preview while adding one)
/// use one definition.
enum MedicineStatus { available, low, outOfStock }

/// The backend fixed the low-stock threshold internally at 10 for every
/// pharmacy (`PharmacyMedicine::LOW_STOCK_THRESHOLD`) — it's no longer a
/// per-item value the client sets or reads.
const int lowStockThreshold = 10;

MedicineStatus medicineStatusFor(int quantity) {
  if (quantity <= 0) return MedicineStatus.outOfStock;
  if (quantity <= lowStockThreshold) return MedicineStatus.low;
  return MedicineStatus.available;
}

/// A medicine as stocked by the current pharmacy (a `pharmacy_medicine`
/// record), combining the pharmacy's stock fields with the underlying
/// catalog medicine's descriptive fields.
class Medicine {
  final int id;
  final int medicineId;
  final String name;
  final String? nameAr;
  final String? activeIngredient;
  final String? imageUrl;
  final double price;
  final int quantity;
  final bool isAvailable;

  /// Server-computed stock flags from `GET /pharmacy/medicines`, preferred
  /// over the local [medicineStatusFor] computation when present.
  final bool? isLowStock;
  final bool? isOutOfStock;

  const Medicine({
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

  MedicineStatus get status {
    if (isOutOfStock != null && isLowStock != null) {
      if (isOutOfStock!) return MedicineStatus.outOfStock;
      if (isLowStock!) return MedicineStatus.low;
      return MedicineStatus.available;
    }
    return medicineStatusFor(quantity);
  }
}
