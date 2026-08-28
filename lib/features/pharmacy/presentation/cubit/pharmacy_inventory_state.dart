import '../../domain/entities/medicine.dart';

sealed class PharmacyInventoryState {
  const PharmacyInventoryState();
}

class PharmacyInventoryLoading extends PharmacyInventoryState {
  const PharmacyInventoryLoading();
}

class PharmacyInventoryLoadFailure extends PharmacyInventoryState {
  final String message;

  const PharmacyInventoryLoadFailure(this.message);
}

class PharmacyInventoryLoaded extends PharmacyInventoryState {
  final List<Medicine> medicines;
  final String query;
  final MedicineStatusFilter filter;

  /// Quantities the pharmacist has adjusted with the +/- steppers but not
  /// saved yet, keyed by `Medicine.id`. Cleared by a fresh [load] (including
  /// the reload after a successful save) — never patched in place, so the
  /// list can't drift from what the server actually has.
  final Map<int, int> pendingQuantities;
  final bool isSaving;
  final String? saveError;

  const PharmacyInventoryLoaded({
    required this.medicines,
    this.query = '',
    this.filter = MedicineStatusFilter.all,
    this.pendingQuantities = const {},
    this.isSaving = false,
    this.saveError,
  });

  int quantityFor(Medicine medicine) => pendingQuantities[medicine.id] ?? medicine.quantity;

  /// For an item with no pending edit, defers to `medicine.status` (which
  /// prefers the backend's `is_low_stock`/`is_out_of_stock` flags) so this
  /// screen's badges agree with the Medicines tab's. Only recomputes from
  /// the raw quantity for an item currently being edited, since the
  /// server's flags describe the *saved* quantity and would be stale the
  /// moment a pending edit changes what's on screen.
  MedicineStatus statusFor(Medicine medicine) {
    if (!pendingQuantities.containsKey(medicine.id)) return medicine.status;
    return medicineStatusFor(quantityFor(medicine));
  }

  bool get hasPendingChanges => pendingQuantities.isNotEmpty;

  List<Medicine> get filteredMedicines {
    final normalizedQuery = query.trim().toLowerCase();
    return medicines.where((medicine) {
      final matchesFilter = switch (filter) {
        MedicineStatusFilter.all => true,
        MedicineStatusFilter.available => statusFor(medicine) == MedicineStatus.available,
        MedicineStatusFilter.low => statusFor(medicine) == MedicineStatus.low,
        MedicineStatusFilter.outOfStock => statusFor(medicine) == MedicineStatus.outOfStock,
      };
      if (!matchesFilter) return false;
      if (normalizedQuery.isEmpty) return true;
      return medicine.name.toLowerCase().contains(normalizedQuery) ||
          medicine.displayName.toLowerCase().contains(normalizedQuery) ||
          (medicine.activeIngredient?.toLowerCase().contains(normalizedQuery) ?? false);
    }).toList();
  }

  /// Tallies all three stock-status counts in one pass over [medicines]
  /// instead of three (one per status) — also lets a `BlocSelector` skip
  /// rebuilding the stats card on state changes that don't affect it (e.g.
  /// a search-query edit), since two tallies with equal counts compare
  /// equal via this record's built-in structural equality.
  ({int available, int low, int outOfStock}) get statusTally {
    var available = 0, low = 0, outOfStock = 0;
    for (final medicine in medicines) {
      switch (statusFor(medicine)) {
        case MedicineStatus.available:
          available++;
        case MedicineStatus.low:
          low++;
        case MedicineStatus.outOfStock:
          outOfStock++;
      }
    }
    return (available: available, low: low, outOfStock: outOfStock);
  }

  PharmacyInventoryLoaded copyWith({
    List<Medicine>? medicines,
    String? query,
    MedicineStatusFilter? filter,
    Map<int, int>? pendingQuantities,
    bool? isSaving,
    String? saveError,
    bool clearSaveError = false,
  }) {
    return PharmacyInventoryLoaded(
      medicines: medicines ?? this.medicines,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      pendingQuantities: pendingQuantities ?? this.pendingQuantities,
      isSaving: isSaving ?? this.isSaving,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
    );
  }
}
