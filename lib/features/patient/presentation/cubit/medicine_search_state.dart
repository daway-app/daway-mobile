import '../../domain/entities/searched_medicine.dart';

sealed class MedicineSearchState {
  const MedicineSearchState();
}

/// No query typed (or submitted yet) — the screen shows "الأكثر بحثاً".
class MedicineSearchIdle extends MedicineSearchState {
  const MedicineSearchIdle();
}

class MedicineSearchLoading extends MedicineSearchState {
  const MedicineSearchLoading();
}

class MedicineSearchLoadFailure extends MedicineSearchState {
  final String message;

  const MedicineSearchLoadFailure(this.message);
}

class MedicineSearchLoaded extends MedicineSearchState {
  final String query;
  final List<SearchedMedicine> results;

  const MedicineSearchLoaded({required this.query, required this.results});
}
