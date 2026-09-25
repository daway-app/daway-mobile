import '../../../../core/helpers/api_result.dart';

abstract class AppInfoRepository {
  /// The installed app's version name, e.g. "1.0.0".
  Future<ApiResult<String>> getVersion();
}
