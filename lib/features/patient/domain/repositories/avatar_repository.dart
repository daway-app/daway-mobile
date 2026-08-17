import 'dart:io';

import '../../../../core/helpers/api_result.dart';

abstract class AvatarRepository {
  /// Uploads the picked image and returns its public URL.
  Future<ApiResult<String>> uploadAvatar(File imageFile);
}
