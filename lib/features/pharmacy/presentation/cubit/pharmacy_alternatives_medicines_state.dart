import '../../domain/entities/medicine.dart';

sealed class PharmacyAlternativesMedicinesState {
  const PharmacyAlternativesMedicinesState();
}

class PharmacyAlternativesMedicinesLoading
    extends PharmacyAlternativesMedicinesState {
  const PharmacyAlternativesMedicinesLoading();
}

class PharmacyAlternativesMedicinesLoadFailure
    extends PharmacyAlternativesMedicinesState {
  final String message;

  const PharmacyAlternativesMedicinesLoadFailure(this.message);
}

class PharmacyAlternativesMedicinesLoaded
    extends PharmacyAlternativesMedicinesState {
  final List<Medicine> medicines;

  /// Ids of medicines that already have an alternative linked — the
  /// "بدائل محددة" summary count, and what marks a tile as already handled.
  final Set<int> alreadyHandledIds;

  /// Ids of medicines that are low/out of stock and don't already have an
  /// alternative — the "أدوية تحتاج بديلاً" summary count. Computed once in
  /// [GetMedicinesWithAlternativeStatusUseCase], not re-derived here.
  final Set<int> needingAlternativeIds;
  final String query;

  const PharmacyAlternativesMedicinesLoaded({
    required this.medicines,
    required this.alreadyHandledIds,
    required this.needingAlternativeIds,
    this.query = '',
  });

  bool isAlreadyHandled(Medicine medicine) =>
      alreadyHandledIds.contains(medicine.id);

  List<Medicine> get filteredMedicines {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return medicines;
    return medicines
        .where(
          (medicine) =>
              medicine.name.toLowerCase().contains(normalizedQuery) ||
              medicine.displayName.toLowerCase().contains(normalizedQuery) ||
              (medicine.activeIngredient?.toLowerCase().contains(
                    normalizedQuery,
                  ) ??
                  false),
        )
        .toList();
  }

  PharmacyAlternativesMedicinesLoaded copyWith({required String query}) {
    return PharmacyAlternativesMedicinesLoaded(
      medicines: medicines,
      alreadyHandledIds: alreadyHandledIds,
      needingAlternativeIds: needingAlternativeIds,
      query: query,
    );
  }
}
