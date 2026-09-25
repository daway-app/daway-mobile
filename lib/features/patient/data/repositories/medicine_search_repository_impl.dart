import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/searched_medicine.dart';
import '../../domain/repositories/medicine_search_repository.dart';
import '../datasources/medicine_search_remote_data_source.dart';
import '../models/searched_medicine_model.dart';

class MedicineSearchRepositoryImpl implements MedicineSearchRepository {
  final MedicineSearchRemoteDataSource _remoteDataSource;

  const MedicineSearchRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<List<SearchedMedicine>>> search(String query) async {
    try {
      final response = await _remoteDataSource.search(query);
      const source = 'GET /medicines/search';
      final body = response.data;
      final data = body is Map<String, dynamic> ? body['data'] : null;
      final medicinesJson = data is Map<String, dynamic> ? data['medicines'] : null;
      if (medicinesJson is! List) {
        throw FormatException('Unexpected $source response shape: $body');
      }

      final medicines = medicinesJson
          .map((json) =>
              SearchedMedicineModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
      return Success(medicines);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
