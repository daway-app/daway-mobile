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

  const PharmacyMedicinesLoaded({
    required this.medicines,
    this.query = '',
    this.filter = MedicineStatusFilter.all,
  });

  List<Medicine> get filteredMedicines {
    final normalizedQuery = query.trim().toLowerCase();
    return medicines.where((medicine) {
      final matchesFilter = switch (filter) {
        MedicineStatusFilter.all => true,
        MedicineStatusFilter.available => medicine.status == MedicineStatus.available,
        MedicineStatusFilter.low => medicine.status == MedicineStatus.low,
        MedicineStatusFilter.outOfStock => medicine.status == MedicineStatus.outOfStock,
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
  }) {
    return PharmacyMedicinesLoaded(
      medicines: medicines ?? this.medicines,
      query: query ?? this.query,
      filter: filter ?? this.filter,
    );
  }
}
