import 'dart:io';

import '../../../../core/helpers/api_result.dart';
import '../repositories/avatar_repository.dart';

class UploadAvatarUseCase {
  final AvatarRepository _repository;

  const UploadAvatarUseCase(this._repository);

  Future<ApiResult<String>> call(File imageFile) => _repository.uploadAvatar(imageFile);
}
