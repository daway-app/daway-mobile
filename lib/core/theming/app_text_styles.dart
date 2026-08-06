import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

abstract class AppTextStyles {
  static TextStyle get screenTitle => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      );

  static TextStyle get cardTitle => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryTeal,
      );

  static TextStyle get cardDescription => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.greyText,
      );

  static TextStyle get footerText => TextStyle(
        fontSize: 14.sp,
        color: AppColors.greyText,
      );
}
