import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/domain/entities/category.dart';
import 'package:daway_app/features/patient/domain/entities/category_medicine.dart';
import 'package:daway_app/features/patient/domain/entities/category_medicines_result.dart';
import 'package:daway_app/features/patient/domain/repositories/category_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_category_medicines_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCategoryRepository implements CategoryRepository {
  ApiResult<CategoryMedicinesResult> result = const Success(
    CategoryMedicinesResult(medicines: [], total: 0, currentPage: 1, lastPage: 1),
  );
  Map<String, dynamic>? lastCallArgs;

  @override
  Future<ApiResult<List<Category>>> getCategories() async => throw UnimplementedError();

  @override
  Future<ApiResult<CategoryMedicinesResult>> getCategoryMedicines({
    required String categorySlug,
    String? subcategorySlug,
    String? dosageForm,
    String? query,
    int page = 1,
    int perPage = 20,
  }) async {
    lastCallArgs = {
      'categorySlug': categorySlug,
      'subcategorySlug': subcategorySlug,
      'dosageForm': dosageForm,
      'query': query,
      'page': page,
      'perPage': perPage,
    };
    return result;
  }

  @override
  Future<ApiResult<List<String>>> getDosageForms() async => throw UnimplementedError();
}

void main() {
  test('forwards all filter arguments to the repository', () async {
    final repository = _FakeCategoryRepository();
    final useCase = GetCategoryMedicinesUseCase(repository);

    await useCase(
      categorySlug: 'vitamins-supplements',
      subcategorySlug: 'protein-supplements',
      dosageForm: 'حبوب',
      query: 'panadol',
      page: 2,
      perPage: 10,
    );

    expect(repository.lastCallArgs, {
      'categorySlug': 'vitamins-supplements',
      'subcategorySlug': 'protein-supplements',
      'dosageForm': 'حبوب',
      'query': 'panadol',
      'page': 2,
      'perPage': 10,
    });
  });

  test('returns the repository result unchanged on success', () async {
    final repository = _FakeCategoryRepository();
    repository.result = const Success(CategoryMedicinesResult(
      medicines: [CategoryMedicine(id: 1, tradeName: 'PANADOL')],
      total: 1,
      currentPage: 1,
      lastPage: 1,
    ));
    final useCase = GetCategoryMedicinesUseCase(repository);

    final result = await useCase(categorySlug: 'medicines');

    expect(result, isA<Success<CategoryMedicinesResult>>());
    expect((result as Success).data.medicines.single.tradeName, 'PANADOL');
  });

  test('surfaces a repository failure unchanged', () async {
    final repository = _FakeCategoryRepository();
    repository.result = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final useCase = GetCategoryMedicinesUseCase(repository);

    final result = await useCase(categorySlug: 'medicines');

    expect(result, isA<ApiError<CategoryMedicinesResult>>());
  });
}
