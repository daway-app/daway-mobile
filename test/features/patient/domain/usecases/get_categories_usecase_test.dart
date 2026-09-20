import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/domain/entities/category.dart';
import 'package:daway_app/features/patient/domain/entities/category_medicines_result.dart';
import 'package:daway_app/features/patient/domain/repositories/category_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_categories_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCategoryRepository implements CategoryRepository {
  ApiResult<List<Category>> result = const Success([]);

  @override
  Future<ApiResult<List<Category>>> getCategories() async => result;

  @override
  Future<ApiResult<CategoryMedicinesResult>> getCategoryMedicines({
    required String categorySlug,
    String? subcategorySlug,
    String? dosageForm,
    String? query,
    int page = 1,
    int perPage = 20,
  }) async =>
      throw UnimplementedError();

  @override
  Future<ApiResult<List<String>>> getDosageForms() async => throw UnimplementedError();
}

void main() {
  test('returns the categories from the repository, with no token required', () async {
    final repository = _FakeCategoryRepository();
    repository.result = const Success([
      Category(id: 3, nameAr: 'أدوية', slug: 'medicines'),
    ]);
    final useCase = GetCategoriesUseCase(repository);

    final result = await useCase();

    expect(result, isA<Success<List<Category>>>());
    expect((result as Success).data.single.slug, 'medicines');
  });

  test('surfaces a repository failure unchanged', () async {
    final repository = _FakeCategoryRepository();
    repository.result = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final useCase = GetCategoriesUseCase(repository);

    final result = await useCase();

    expect(result, isA<ApiError<List<Category>>>());
  });
}
