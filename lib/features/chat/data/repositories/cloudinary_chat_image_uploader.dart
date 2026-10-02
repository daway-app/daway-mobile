import 'dart:io';

import '../../../../core/helpers/api_result.dart';
import '../../../patient/domain/repositories/avatar_repository.dart';
import '../../domain/repositories/chat_image_uploader.dart';

/// Reuses the app's existing Cloudinary upload (unsigned preset) rather than
/// duplicating it — chat pictures go to the same place as avatars.
class CloudinaryChatImageUploader implements ChatImageUploader {
  final AvatarRepository _avatarRepository;

  const CloudinaryChatImageUploader(this._avatarRepository);

  @override
  Future<ApiResult<String>> upload(String imagePath) =>
      _avatarRepository.uploadAvatar(File(imagePath));
}
