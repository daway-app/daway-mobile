import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../cubit/complete_profile_cubit.dart';
import '../cubit/complete_profile_state.dart';

/// Avatar circle with an edit pencil badge. Picking a source (camera/gallery)
/// is a plain UI interaction handled here; the resulting file is handed to
/// the cubit, which owns the upload business logic.
class ProfileAvatarPicker extends StatelessWidget {
  const ProfileAvatarPicker({super.key});

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

    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (picked == null || !context.mounted) return;

    context.read<CompleteProfileCubit>().avatarSelected(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompleteProfileCubit, CompleteProfileState>(
      buildWhen: (previous, current) =>
          previous.formData.avatarLocalPath != current.formData.avatarLocalPath ||
          previous.formData.isUploadingAvatar != current.formData.isUploadingAvatar ||
          previous.formData.avatarError != current.formData.avatarError,
      builder: (context, state) {
        final localPath = state.formData.avatarLocalPath;
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
                  child: localPath != null
                      ? Image.file(File(localPath), fit: BoxFit.cover)
                      : Icon(Icons.person, size: 48.sp, color: AppColors.grey),
                ),
                if (state.formData.isUploadingAvatar)
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
            if (state.formData.avatarError != null) ...[
              SizedBox(height: 8.h),
              Text(
                state.formData.avatarError!,
                style: AppTextStyles.errorText,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );
      },
    );
  }
}
