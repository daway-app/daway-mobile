import '../../domain/entities/medicine.dart';

sealed class PharmacyMedicinesState {
  const PharmacyMedicinesState();
}

class PharmacyMedicinesLoading extends PharmacyMedicinesState {
  const PharmacyMedicinesLoading();
}

class PharmacyMedicinesLoadFailure extends PharmacyMedicinesState {
  final String message;

  const PharmacyMedicinesLoadFailure(this.message);
}

class PharmacyMedicinesLoaded extends PharmacyMedicinesState {
  final List<Medicine> medicines;
  final String query;
  final MedicineStatusFilter filter;

  /// Quantities set with a +/- stepper that the server has not confirmed yet,
  /// keyed by `Medicine.id`. They are shown in place of the medicine's own
  /// quantity until the save lands (the medicine is then updated and the entry
  /// removed) or fails (the entry is removed and the quantity goes back).
  final Map<int, int> pendingQuantities;

  /// Why the last stepper save failed, until the next stepper tap.
  final String? stockError;

  const PharmacyMedicinesLoaded({
    required this.medicines,
    this.query = '',
    this.filter = MedicineStatusFilter.all,
    this.pendingQuantities = const {},
    this.stockError,
  });

  int quantityFor(Medicine medicine) => pendingQuantities[medicine.id] ?? medicine.quantity;

  /// For a medicine with a stepper edit on its way, worked out from the quantity
  /// shown (the server's flags describe the saved one); otherwise the
  /// medicine's own, which prefers the server's flags.
  MedicineStatus statusFor(Medicine medicine) {
    final pending = pendingQuantities[medicine.id];
    return pending == null ? medicine.status : medicineStatusFor(pending);
  }

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

  PharmacyMedicinesLoaded copyWith({
    List<Medicine>? medicines,
    String? query,
    MedicineStatusFilter? filter,
    Map<int, int>? pendingQuantities,
    String? stockError,
    bool clearStockError = false,
  }) {
    return PharmacyMedicinesLoaded(
      medicines: medicines ?? this.medicines,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      pendingQuantities: pendingQuantities ?? this.pendingQuantities,
      stockError: clearStockError ? null : (stockError ?? this.stockError),
    );
  }
}
