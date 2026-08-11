import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_colors.dart';
import '../theming/app_text_styles.dart';
import 'app_custom_button.dart';
import 'app_logo.dart';

/// Confirmation dialog shown before ending the user's session. Purely
/// presentational — the caller decides what happens when the user confirms.
class LogoutConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const LogoutConfirmationDialog({super.key, required this.onConfirm});

  static Future<void> show(BuildContext context, {required VoidCallback onConfirm}) {
    return showDialog<void>(
      context: context,
      builder: (_) => LogoutConfirmationDialog(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 64),
            SizedBox(height: 20.h),
            Text(
              'تأكيد تسجيل الخروج',
              style: AppTextStyles.authTitle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'هل أنت متأكد أنك تريد تسجيل الخروج من التطبيق؟',
              style: AppTextStyles.authSubtitle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            AppCustomButton(
              backgroundColor: AppColors.mainTeal,
              text: 'تأكيد',
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.mainTeal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    color: AppColors.mainTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 16.sp, color: AppColors.grey),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    'لن يتم حذف أي بيانات طبية خاصة بك',
                    style: AppTextStyles.helperText,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
