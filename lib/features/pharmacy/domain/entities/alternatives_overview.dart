import 'medicine.dart';

/// `GET /pharmacy/medicines/{id}/alternatives` (same-active-ingredient
/// candidates from this pharmacy's own stock) combined with which of those
/// candidates this pharmacy has already manually linked as an official
/// alternative for [baseMedicine] — see PharmacyAlternativesRepositoryImpl
/// for why these come from two separate endpoints.
class AlternativesOverview {
  final Medicine baseMedicine;
  final List<Medicine> candidates;
  final Set<int> selectedAlternativeIds;

  const AlternativesOverview({
    required this.baseMedicine,
    required this.candidates,
    required this.selectedAlternativeIds,
  });
}
