/// A medicine returned by a category listing (`GET /categories/{slug}/medicines`).
/// The backend does not (yet) return an image or a per-pharmacy availability
/// count for these list items — see [CategoryMedicinesResult] callers.
class CategoryMedicine {
  final int id;
  final String tradeName;
  final String? genericName;
  final String? dosageForm;

  const CategoryMedicine({
    required this.id,
    required this.tradeName,
    this.genericName,
    this.dosageForm,
  });
}
