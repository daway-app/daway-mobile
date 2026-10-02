import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/dashed_border_box.dart';

/// The dashed "upload your medicines file" card a pharmacy with no medicines
/// yet sees at the top of its home: an upload icon, a title, a line about the
/// Excel file, and the "اختيار ملف" button that [onPickFile] answers.
class AddMedicinesFileCard extends StatelessWidget {
  final VoidCallback onPickFile;

  const AddMedicinesFileCard({super.key, required this.onPickFile});

  @override
  Widget build(BuildContext context) {
    return DashedBorderBox(
      color: AppColors.mainTeal,
      backgroundColor: AppColors.permissionIconBg,
      radius: 8.r,
      dashLength: 8.w,
      gapLength: 8.w,
      child: Container(
        constraints: BoxConstraints(minHeight: 215.h),
        alignment: Alignment.center,
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.iconBlueBorder, width: 0.8),
              ),
              child: SvgPicture.asset(
                'assets/icons/upload_icon.svg',
                width: 24.w,
                height: 24.w,
              ),
            ),
            SizedBox(height: 13.h),
            Text(
              'رفع ملف المنتجات',
              textAlign: TextAlign.center,
              style: AppTextStyles.pharmacyUploadTitle,
            ),
            Text(
              'ارفع ملف Excel يحتوي على منتجات الصيدلية.',
              textAlign: TextAlign.center,
              style: AppTextStyles.pharmacyUploadSubtitle,
            ),
            SizedBox(height: 14.h),
            GestureDetector(
              onTap: onPickFile,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 142.w,
                height: 43.h,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.iconBlueBorder,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  'اختيار ملف',
                  style: AppTextStyles.pharmacyUploadButton,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
