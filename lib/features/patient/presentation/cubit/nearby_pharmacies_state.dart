import '../../../../core/helpers/arabic_search.dart';
import '../../domain/entities/nearby_pharmacy.dart';

sealed class NearbyPharmaciesState {
  const NearbyPharmaciesState();
}

class NearbyPharmaciesLoading extends NearbyPharmaciesState {
  const NearbyPharmaciesLoading();
}

class NearbyPharmaciesLoadFailure extends NearbyPharmaciesState {
  final String message;

  const NearbyPharmaciesLoadFailure(this.message);
}

class NearbyPharmaciesLoaded extends NearbyPharmaciesState {
  final List<NearbyPharmacy> pharmacies;
  final double? userLatitude;
  final double? userLongitude;
  final String query;
  final NearbyPharmacy? selectedPharmacy;
  final bool isLoadingHours;
  final String? selectedWorkingHours;

  const NearbyPharmaciesLoaded({
    required this.pharmacies,
    this.userLatitude,
    this.userLongitude,
    this.query = '',
    this.selectedPharmacy,
    this.isLoadingHours = false,
    this.selectedWorkingHours,
  });

  bool get hasUserLocation => userLatitude != null && userLongitude != null;

  List<NearbyPharmacy> get visiblePharmacies {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return pharmacies;
    return pharmacies.where((pharmacy) => arabicContains(pharmacy.name, trimmed)).toList();
  }

  NearbyPharmaciesLoaded copyWith({
    List<NearbyPharmacy>? pharmacies,
    String? query,
    NearbyPharmacy? selectedPharmacy,
    bool clearSelection = false,
    bool? isLoadingHours,
    String? selectedWorkingHours,
    bool clearWorkingHours = false,
  }) {
    return NearbyPharmaciesLoaded(
      pharmacies: pharmacies ?? this.pharmacies,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      query: query ?? this.query,
      selectedPharmacy: clearSelection ? null : (selectedPharmacy ?? this.selectedPharmacy),
      isLoadingHours: isLoadingHours ?? this.isLoadingHours,
      selectedWorkingHours:
          clearSelection || clearWorkingHours ? null : (selectedWorkingHours ?? this.selectedWorkingHours),
    );
  }
}
