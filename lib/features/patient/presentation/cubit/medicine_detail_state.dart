import '../../domain/entities/medicine_detail.dart';
import '../../domain/entities/medicine_pharmacy_offer.dart';

sealed class MedicineDetailState {
  const MedicineDetailState();
}

class MedicineDetailLoading extends MedicineDetailState {
  const MedicineDetailLoading();
}

class MedicineDetailLoadFailure extends MedicineDetailState {
  final String message;

  const MedicineDetailLoadFailure(this.message);
}

class MedicineDetailLoaded extends MedicineDetailState {
  final MedicineDetail medicine;
  final List<MedicinePharmacyOffer> pharmacies;

  /// `GET /medicines/{id}` has no "is this saved" field of its own, so
  /// [MedicineDetailCubit.load] resolves this by checking the patient's
  /// favorites list separately (falling back to false only if that fetch
  /// fails) — not read directly off the medicine response.
  final bool isFavorite;
  final bool isTogglingFavorite;

  const MedicineDetailLoaded({
    required this.medicine,
    required this.pharmacies,
    this.isFavorite = false,
    this.isTogglingFavorite = false,
  });

  MedicineDetailLoaded copyWith({
    bool? isFavorite,
    bool? isTogglingFavorite,
  }) {
    return MedicineDetailLoaded(
      medicine: medicine,
      pharmacies: pharmacies,
      isFavorite: isFavorite ?? this.isFavorite,
      isTogglingFavorite: isTogglingFavorite ?? this.isTogglingFavorite,
    );
  }
}
