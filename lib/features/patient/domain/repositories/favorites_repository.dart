import '../../../../core/helpers/api_result.dart';
import '../entities/favorite_medicine.dart';

abstract class FavoritesRepository {
  Future<ApiResult<List<FavoriteMedicine>>> getFavoriteMedicines({required String token});

  Future<ApiResult<void>> addFavoriteMedicine({
    required String token,
    required int medicineId,
  });

  Future<ApiResult<void>> removeFavoriteMedicine({
    required String token,
    required int medicineId,
  });
}
