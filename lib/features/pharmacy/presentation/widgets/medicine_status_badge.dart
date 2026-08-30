import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../domain/entities/medicine.dart';

/// Shared by every widget that colors itself off a [MedicineStatus] — keeps
/// the available/low/out-of-stock colors defined once instead of each caller
/// re-deriving the same switch.
Color colorForMedicineStatus(MedicineStatus status) => switch (status) {
  MedicineStatus.available => AppColors.success,
  MedicineStatus.low => AppColors.warning,
  MedicineStatus.outOfStock => AppColors.error,
};

class MedicineStatusBadge extends StatelessWidget {
  final MedicineStatus status;

  const MedicineStatusBadge({super.key, required this.status});

  (String, Color) get _labelAndColor => switch (status) {
    MedicineStatus.available => ('متوفر', colorForMedicineStatus(status)),
    MedicineStatus.low => ('منخفض', colorForMedicineStatus(status)),
    MedicineStatus.outOfStock => ('نافد', colorForMedicineStatus(status)),
  };

  @override
  Widget build(BuildContext context) {
    final (label, color) = _labelAndColor;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          SizedBox(width: 6.w),
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}
