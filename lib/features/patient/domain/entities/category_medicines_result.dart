import 'category_medicine.dart';

/// One page of a category's (optionally filtered) medicines list.
class CategoryMedicinesResult {
  final List<CategoryMedicine> medicines;
  final int total;
  final int currentPage;
  final int lastPage;

  const CategoryMedicinesResult({
    required this.medicines,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasMorePages => currentPage < lastPage;
}
