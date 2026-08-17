import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/erroring/error_handler.dart';
import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../domain/repositories/avatar_repository.dart';

/// Uploads directly to Cloudinary using an unsigned upload preset — there is
/// no image-upload endpoint on our own backend, and an unsigned preset is the
/// only Cloudinary credential safe to ship inside a client app (no API secret
/// involved). [cloudName] and [uploadPreset] are read from .env by the DI setup.
class CloudinaryAvatarRepositoryImpl implements AvatarRepository {
  final Dio _dio;
  final String cloudName;
  final String uploadPreset;

  const CloudinaryAvatarRepositoryImpl(
    this._dio, {
    required this.cloudName,
    required this.uploadPreset,
  });

  @override
  Future<ApiResult<String>> uploadAvatar(File imageFile) async {
    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      return const ApiError(
        UnknownFailure('إعدادات رفع الصور غير مكتملة، يرجى التواصل مع الدعم'),
      );
    }

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
        'upload_preset': uploadPreset,
      });

      final response = await _dio.post<Map<String, dynamic>>(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
        data: formData,
      );

      final url = response.data?['secure_url'] as String?;
      if (url == null || url.isEmpty) {
        return const ApiError(UnknownFailure('تعذر رفع الصورة، يرجى المحاولة لاحقاً'));
      }
      return Success(url);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
