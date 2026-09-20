import '../../domain/entities/category_medicine.dart';

sealed class CategoryMedicinesState {
  const CategoryMedicinesState();
}

class CategoryMedicinesLoading extends CategoryMedicinesState {
  const CategoryMedicinesLoading();
}

class CategoryMedicinesLoadFailure extends CategoryMedicinesState {
  final String message;

  const CategoryMedicinesLoadFailure(this.message);
}

class CategoryMedicinesLoaded extends CategoryMedicinesState {
  final List<CategoryMedicine> medicines;
  final int total;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;
  final String query;
  final String? subcategorySlug;
  final String? dosageForm;
  final List<String> dosageForms;

  const CategoryMedicinesLoaded({
    required this.medicines,
    required this.total,
    required this.currentPage,
    required this.lastPage,
    this.isLoadingMore = false,
    this.query = '',
    this.subcategorySlug,
    this.dosageForm,
    this.dosageForms = const [],
  });

  bool get hasMorePages => currentPage < lastPage;
  bool get hasActiveFilters => subcategorySlug != null || dosageForm != null;

  CategoryMedicinesLoaded copyWith({
    List<CategoryMedicine>? medicines,
    int? total,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
  }) {
    return CategoryMedicinesLoaded(
      medicines: medicines ?? this.medicines,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      query: query,
      subcategorySlug: subcategorySlug,
      dosageForm: dosageForm,
      dosageForms: dosageForms,
    );
  }
}
