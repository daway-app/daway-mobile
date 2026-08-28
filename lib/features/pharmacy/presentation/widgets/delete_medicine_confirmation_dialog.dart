import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';

/// Confirmation dialog shown before removing a medicine from the pharmacy's
/// stock — purely presentational, the caller decides what happens on confirm.
class DeleteMedicineConfirmationDialog extends StatelessWidget {
  final String medicineName;
  final VoidCallback onConfirm;

  const DeleteMedicineConfirmationDialog({
    super.key,
    required this.medicineName,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required String medicineName,
    required VoidCallback onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) =>
          DeleteMedicineConfirmationDialog(medicineName: medicineName, onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, size: 48.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text('حذف الدواء', style: AppTextStyles.authTitle, textAlign: TextAlign.center),
            SizedBox(height: 8.h),
            Text(
              'هل أنت متأكد أنك تريد حذف "$medicineName" من مخزون الصيدلية؟',
              style: AppTextStyles.authSubtitle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            AppCustomButton(
              backgroundColor: AppColors.error,
              text: 'حذف',
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
          ],
        ),
      ),
    );
  }
}
