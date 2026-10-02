import '../../../../core/helpers/api_result.dart';

/// Uploads a picked image and returns its public link.
abstract class ChatImageUploader {
  Future<ApiResult<String>> upload(String imagePath);
}
