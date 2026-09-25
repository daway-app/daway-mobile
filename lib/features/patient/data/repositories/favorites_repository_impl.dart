import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../../core/helpers/paginated_fetch.dart';
import '../../domain/entities/favorite_medicine.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_data_source.dart';
import '../models/favorite_medicine_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource _remoteDataSource;

  const FavoritesRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<List<FavoriteMedicine>>> getFavoriteMedicines({
    required String token,
  }) async {
    try {
      final medicinesJson = await fetchAllPages(
        source: 'GET /patient/favorites/medicines',
        fetchPage: (page) async =>
            (await _remoteDataSource.getFavoriteMedicines(token: token, page: page)).data,
      );
      final medicines = medicinesJson
          .map((json) =>
              FavoriteMedicineModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
      return Success(medicines);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
