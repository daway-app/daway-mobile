import '../../../../core/helpers/api_result.dart';
import '../entities/searched_medicine.dart';

abstract class MedicineSearchRepository {
  Future<ApiResult<List<SearchedMedicine>>> search(String query);
}
