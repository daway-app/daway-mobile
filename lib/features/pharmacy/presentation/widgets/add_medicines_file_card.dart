import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/dashed_border_box.dart';

/// The dashed "add the file of the medicines your pharmacy has" prompt a
/// pharmacy with no medicines yet sees at the top of its home.
class AddMedicinesFileCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddMedicinesFileCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: DashedBorderBox(
        color: AppColors.mainTeal,
        backgroundColor: AppColors.accountIconBg,
        radius: 8.r,
        dashLength: 8.w,
        gapLength: 8.w,
        child: Container(
          constraints: BoxConstraints(minHeight: 156.h),
          alignment: Alignment.center,
          // 92.5 each side is what the design's 92/93 padding leaves the
          // text: a 207-wide column.
          padding: EdgeInsets.symmetric(horizontal: 92.5.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/icons/file_text_icon.svg', width: 24.w, height: 24.w),
              SizedBox(height: 10.h),
              // The line break is the design's, kept explicit so the wording
              // wraps the same whatever the font's exact widths are.
              Text(
                'أضف ملف الادوية و المنتجات\nالمتوفرة في صيدليتك',
                textAlign: TextAlign.center,
                style: AppTextStyles.pharmacyAddFileText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
