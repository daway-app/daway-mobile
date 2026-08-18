import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../theming/app_colors.dart';
import '../theming/app_text_styles.dart';

/// Avatar/logo circle with an edit pencil badge. Picking a source
/// (camera/gallery) is a plain UI interaction handled here; the resulting
/// file is handed back via [onImagePicked] — the caller's cubit owns the
/// upload business logic, so this widget stays reusable across any screen
/// that edits a profile picture (patient profile, pharmacy profile, ...).
class ProfileAvatarPicker extends StatelessWidget {
  final String? avatarLocalPath;
  final String? avatarUrl;
  final bool isUploading;
  final String? errorMessage;
  final ValueChanged<File> onImagePicked;

  const ProfileAvatarPicker({
    super.key,
    required this.avatarLocalPath,
    this.avatarUrl,
    required this.isUploading,
    required this.errorMessage,
    required this.onImagePicked,
  });

  Future<void> _pickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            ListTile(
              leading: Icon(Icons.photo_camera_outlined, color: AppColors.mainTeal),
              title: const Text('التقاط صورة'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: AppColors.mainTeal),
              title: const Text('اختيار من المعرض'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;

    try {
      final picked = await ImagePicker().pickImage(source: source, imageQuality: 80);
      if (picked == null || !context.mounted) return;

      onImagePicked(File(picked.path));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح الكاميرا، تحقق من صلاحيات التطبيق')),
      );
    }
  }

  Widget _buildImage() {
    if (avatarLocalPath != null) {
      return Image.file(File(avatarLocalPath!), fit: BoxFit.cover);
    }
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return Image.network(
        avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.person,
          size: 48.sp,
          color: AppColors.grey,
        ),
      );
    }
    return Icon(Icons.person, size: 48.sp, color: AppColors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: _buildImage(),
            ),
            if (isUploading)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _pickImage(context),
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: const BoxDecoration(
                    color: AppColors.mainTeal,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit, size: 16.sp, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        if (errorMessage != null) ...[
          SizedBox(height: 8.h),
          Text(errorMessage!, style: AppTextStyles.errorText, textAlign: TextAlign.center),
        ],
      ],
    );
  }
}
