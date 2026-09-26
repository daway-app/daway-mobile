import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/medicine.dart';

/// The small tinted tag on a product card that says how the stock stands:
/// متوفر, مخزون منخفض or نافد.
class ProductStatusBadge extends StatelessWidget {
  final MedicineStatus status;

  const ProductStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, textColor, tint) = switch (status) {
      MedicineStatus.available => (
        'متوفر',
        AppColors.productAvailableText,
        AppColors.productAvailableTint,
      ),
      MedicineStatus.low => (
        'مخزون منخفض',
        AppColors.statLowStock,
        AppColors.productLowStockTint,
      ),
      MedicineStatus.outOfStock => (
        'نافد',
        AppColors.statOutOfStock,
        AppColors.productOutOfStockTint,
      ),
    };

    return Container(
      // 2 above and below the 17 line: the badge is 21 tall.
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(4.r)),
      child: Text(label, style: AppTextStyles.pharmacyProductBadge.copyWith(color: textColor)),
    );
  }
}
