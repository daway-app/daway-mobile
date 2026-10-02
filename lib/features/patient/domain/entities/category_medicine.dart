/// A medicine returned by a category listing (`GET /categories/{slug}/medicines`).
/// The rows are catalogue entries; [medicineId] points at the pharmacy-stocked
/// medicine behind one (null when no pharmacy carries it), and is what the
/// detail page opens.
class CategoryMedicine {
  final int id;
  final String tradeName;
  final String? genericName;
  final String? dosageForm;
  final int? medicineId;
  final String? imageUrl;

  const CategoryMedicine({
    required this.id,
    required this.tradeName,
    this.genericName,
    this.dosageForm,
    this.medicineId,
    this.imageUrl,
  });
}
