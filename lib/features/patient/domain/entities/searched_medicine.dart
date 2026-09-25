/// A medicine returned by `GET /medicines/search` — only the pharmacy-backed
/// results (`data.medicines`), which carry a real image and live
/// availability. The response's `data.moh_catalog` entries are reference-only
/// (no image, no per-pharmacy count) and don't fit this search results card,
/// so they're left unmapped.
class SearchedMedicine {
  final int id;
  final String tradeName;
  final String? activeIngredient;
  final String? imageUrl;
  final bool isAvailable;
  final int availablePharmaciesCount;

  const SearchedMedicine({
    required this.id,
    required this.tradeName,
    this.activeIngredient,
    this.imageUrl,
    required this.isAvailable,
    required this.availablePharmaciesCount,
  });
}
