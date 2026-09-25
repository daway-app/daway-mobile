import '../../../../core/helpers/api_result.dart';
import '../entities/favorite_medicine.dart';

abstract class FavoritesRepository {
  Future<ApiResult<List<FavoriteMedicine>>> getFavoriteMedicines({required String token});
}
