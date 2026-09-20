import '../../../../core/helpers/api_result.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Public endpoint — no session/token needed, unlike most patient use cases.
class GetCategoriesUseCase {
  final CategoryRepository _repository;

  const GetCategoriesUseCase(this._repository);

  Future<ApiResult<List<Category>>> call() => _repository.getCategories();
}
