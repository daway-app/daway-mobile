/// A medicine the patient has bookmarked, as returned (enriched) by
/// `GET /patient/favorites/medicines`.
class FavoriteMedicine {
  final int medicineId;
  final String tradeName;
  final String? tradeNameAr;
  final String? imageUrl;
  final bool isAvailable;
  final int pharmaciesCount;
  final double? minPrice;

  const FavoriteMedicine({
    required this.medicineId,
    required this.tradeName,
    this.tradeNameAr,
    this.imageUrl,
    required this.isAvailable,
    required this.pharmaciesCount,
    this.minPrice,
  });

  /// Arabic name when the catalog has one, otherwise the English name —
  /// `trade_name_ar` is frequently null (not every catalog entry has been
  /// enriched with one yet).
  String get displayName => (tradeNameAr != null && tradeNameAr!.isNotEmpty) ? tradeNameAr! : tradeName;
}
