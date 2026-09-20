import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/domain/entities/category.dart';
import 'package:daway_app/features/patient/domain/entities/category_medicines_result.dart';
import 'package:daway_app/features/patient/domain/repositories/category_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_categories_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/categories_cubit.dart';
import 'package:daway_app/features/patient/presentation/cubit/categories_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _categories = [
  Category(id: 3, nameAr: 'أدوية', slug: 'medicines'),
  Category(id: 4, nameAr: 'العناية بالأسنان', slug: 'dental-care'),
];

class _FakeCategoryRepository implements CategoryRepository {
  ApiResult<List<Category>> result = const Success(_categories);

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
  late _FakeCategoryRepository repository;

  setUp(() {
    repository = _FakeCategoryRepository();
  });

  test('loads the categories on construction', () async {
    final cubit = CategoriesCubit(GetCategoriesUseCase(repository));
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<CategoriesLoaded>());
    expect((cubit.state as CategoriesLoaded).categories, _categories);
  });

  test('surfaces a load failure', () async {
    repository.result = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = CategoriesCubit(GetCategoriesUseCase(repository));
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<CategoriesLoadFailure>());
    expect((cubit.state as CategoriesLoadFailure).message, 'تعذر الاتصال بالخادم');
  });

  test('load() can be called again to retry after a failure', () async {
    repository.result = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = CategoriesCubit(GetCategoriesUseCase(repository));
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, isA<CategoriesLoadFailure>());

    repository.result = const Success(_categories);
    await cubit.load();

    expect(cubit.state, isA<CategoriesLoaded>());
  });
}
