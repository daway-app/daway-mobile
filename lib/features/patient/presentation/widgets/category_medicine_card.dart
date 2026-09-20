import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/category_medicine.dart';

/// A medicine card for a category's results grid.
///
/// The backend's category-medicines list doesn't return a per-medicine image
/// or a "متوفر في N صيدليات" pharmacy count (see `GET
/// /categories/{slug}/medicines`) — this shows a stand-in icon and the
/// medicine's dosage form/generic name instead until the backend adds those
/// fields.
class CategoryMedicineCard extends StatelessWidget {
  final CategoryMedicine medicine;
  final VoidCallback onDetailsTap;

  const CategoryMedicineCard({
    super.key,
    required this.medicine,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryLine = medicine.genericName?.isNotEmpty == true
        ? medicine.genericName
        : medicine.dosageForm;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 184 / 106,
                  child: ColoredBox(
                    color: AppColors.background,
                    child: Center(
                      child: Icon(
                        Icons.medication_outlined,
                        size: 36.sp,
                        color: AppColors.mainTeal,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.h, right: 9.w, left: 9.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        medicine.tradeName,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.categoryMedicineName,
                      ),
                      if (secondaryLine != null && secondaryLine.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          secondaryLine,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.categoryMedicineSubtitle,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 8.w,
              bottom: 12.h,
              child: SizedBox(
                width: 95.w,
                height: 24.h,
                child: OutlinedButton(
                  onPressed: onDetailsTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.mainTeal,
                    backgroundColor: AppColors.permissionIconBg,
                    side: BorderSide(color: AppColors.iconBlueBorder.withAlpha(0xB8)),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  child: Text(
                    'عرض تفاصيل',
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
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
