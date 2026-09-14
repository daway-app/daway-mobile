import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/helpers/cache_busted_url.dart';
import '../../../../core/helpers/image_source_picker.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

/// Account-info screen's avatar: a 96x96 circle (falling back to the
/// patient's first initial when no picture is set) with a small upload
/// badge. Kept separate from [ProfileAvatarPicker] since that widget's
/// look is shared with the pharmacy profile and medicine-image pickers —
/// this one is specific to this screen's redesign.
class PatientProfileAvatar extends StatelessWidget {
  final String name;
  final String? avatarLocalPath;
  final String? avatarUrl;
  final int avatarVersion;
  final bool isUploading;
  final String? errorMessage;
  final ValueChanged<File> onImagePicked;

  const PatientProfileAvatar({
    super.key,
    required this.name,
    required this.avatarLocalPath,
    this.avatarUrl,
    required this.avatarVersion,
    required this.isUploading,
    required this.errorMessage,
    required this.onImagePicked,
  });

  Future<void> _pickImage(BuildContext context) async {
    if (isUploading) return;
    final file = await pickImageFromSourceSheet(context);
    if (file != null) onImagePicked(file);
  }

  Widget _buildInitial() {
    final trimmed = name.trim();
    final letter = trimmed.isNotEmpty ? trimmed[0] : '؟';
    return Text(
      letter,
      style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: AppColors.mainTeal),
    );
  }

  Widget _buildContent() {
    if (avatarLocalPath != null) {
      return ClipOval(
        child: Image.file(
          File(avatarLocalPath!),
          width: 96.w,
          height: 96.w,
          fit: BoxFit.cover,
        ),
      );
    }
    final url = avatarUrl;
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          cacheBustedUrl(url, version: avatarVersion),
          width: 96.w,
          height: 96.w,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitial(),
        ),
      );
    }
    return _buildInitial();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 96.w,
          height: 96.w + 16.w,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: 96.w,
                  height: 96.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.permissionIconBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.mainTeal, width: 2),
                  ),
                  child: _buildContent(),
                ),
              ),
              if (isUploading)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    width: 96.w,
                    height: 96.w,
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
                ),
              // Left-of-center and mostly overlapping the circle (per
              // design), not centered and hanging half below it.
              Positioned(
                left: -8.w,
                top: 50.w,
                child: GestureDetector(
                  onTap: () => _pickImage(context),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.mainTeal,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/uploud_icon.svg',
                      width: 16.w,
                      height: 16.w,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorMessage != null) ...[
          SizedBox(height: 8.h),
          Text(errorMessage!, style: AppTextStyles.errorText, textAlign: TextAlign.center),
        ],
      ],
    );
  }
}
