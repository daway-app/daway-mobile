import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/image_source_picker.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

/// Dashed upload box for the medicine's (optional) photo, on the "add
/// medicine" screen. Distinct from [ProfileAvatarPicker] — that one is a
/// circular avatar edited in place — but both share the same camera/gallery
/// picking flow via [pickImageFromSourceSheet].
class MedicineImagePicker extends StatelessWidget {
  final String? imageLocalPath;
  final String? imageUrl;
  final bool isUploading;
  final String? errorMessage;
  final ValueChanged<File> onImagePicked;

  const MedicineImagePicker({
    super.key,
    required this.imageLocalPath,
    this.imageUrl,
    required this.isUploading,
    required this.errorMessage,
    required this.onImagePicked,
  });

  Future<void> _pickImage(BuildContext context) async {
    final file = await pickImageFromSourceSheet(context);
    if (file != null) onImagePicked(file);
  }

  Widget _buildContent() {
    if (isUploading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (imageLocalPath != null) {
      return Image.file(File(imageLocalPath!), fit: BoxFit.cover);
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(imageUrl!, fit: BoxFit.cover);
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_photo_alternate_outlined, size: 32.sp, color: AppColors.primaryTeal),
          SizedBox(height: 8.h),
          Text('أضف صورة الدواء (اختياري)', style: AppTextStyles.footerText),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickImage(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: CustomPaint(
              painter: _DashedBorderPainter(color: AppColors.primaryTeal),
              child: Container(
                width: double.infinity,
                height: 140.h,
                color: AppColors.background,
                child: _buildContent(),
              ),
            ),
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

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );
    final path = Path()..addRRect(rrect);
    final dashedPath = Path();
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        const dashLength = 6.0;
        const gapLength = 4.0;
        dashedPath.addPath(
          metric.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + gapLength;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => oldDelegate.color != color;
}
