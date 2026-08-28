import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../domain/entities/medicine.dart';

class MedicineStatusBadge extends StatelessWidget {
  final MedicineStatus status;

  const MedicineStatusBadge({super.key, required this.status});

  (String, Color) get _labelAndColor => switch (status) {
        MedicineStatus.available => ('متوفر', AppColors.success),
        MedicineStatus.low => ('منخفض', AppColors.warning),
        MedicineStatus.outOfStock => ('نافد', AppColors.error),
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
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: color),
          ),
          SizedBox(width: 6.w),
          Container(width: 6.w, height: 6.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ],
      ),
    );
  }
}
