/// A medicine from the shared, pharmacy-wide catalog — returned by the
/// catalog search so a pharmacy can pick one to add to its own stock.
class MedicineCatalogItem {
  final int id;
  final String name;
  final String? nameAr;
  final String? activeIngredient;
  final String? imageUrl;

  /// The catalog source (e.g. the pharmacy's own general list vs a Ministry
  /// of Health entry) — shown as a small badge in the suggestions list.
  final String? type;

  const MedicineCatalogItem({
    required this.id,
    required this.name,
    this.nameAr,
    this.activeIngredient,
    this.imageUrl,
    this.type,
  });
}
