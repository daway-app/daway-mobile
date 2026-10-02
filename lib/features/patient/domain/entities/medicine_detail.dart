/// A medicine's own detail, as `GET /medicines/{id}` returns it.
class MedicineDetail {
  final int id;
  final String tradeName;
  final String? imageUrl;

  /// Symptom/use tags (e.g. "الصداع", "خفض الحرارة") shown under the name.
  /// The backend has no field for these yet — always empty until it does;
  /// kept here (rather than left off the entity) so the screen only needs
  /// one change, not a new field threaded through every layer, once it does.
  final List<String> tags;

  const MedicineDetail({
    required this.id,
    required this.tradeName,
    this.imageUrl,
    this.tags = const [],
  });
}
