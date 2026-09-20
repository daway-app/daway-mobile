import '../../../../core/helpers/api_result.dart';
import '../repositories/category_repository.dart';

/// Public endpoint — no session/token needed, unlike most patient use cases.
class GetDosageFormsUseCase {
  final CategoryRepository _repository;

  const GetDosageFormsUseCase(this._repository);

  Future<ApiResult<List<String>>> call() => _repository.getDosageForms();
}
