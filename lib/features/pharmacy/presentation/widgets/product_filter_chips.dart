import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/medicine.dart';

/// The row of stock filters above the product list: "الكل" with the number of
/// products, then one chip per stock status. Each chip is as wide as its label,
/// and the row scrolls sideways if they do not all fit.
class ProductFilterChips extends StatelessWidget {
  /// How many products the pharmacy has, shown on the "الكل" chip.
  final int totalCount;
  final MedicineStatusFilter selected;
  final ValueChanged<MedicineStatusFilter> onSelected;

  const ProductFilterChips({
    super.key,
    required this.totalCount,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final chips = [
      (MedicineStatusFilter.all, 'الكل($totalCount)'),
      (MedicineStatusFilter.available, 'متوفر'),
      (MedicineStatusFilter.low, 'مخزون منخفض'),
      (MedicineStatusFilter.outOfStock, 'نافد'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < chips.length; i++) ...[
            if (i > 0) SizedBox(width: 8.w),
            _FilterChip(
              label: chips[i].$2,
              isSelected: chips[i].$1 == selected,
              onTap: () => onSelected(chips[i].$1),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      excludeSemantics: true,
      label: label,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          // 33.1 tall, as in the design, and taller only when the text is
          // enlarged past it.
          constraints: BoxConstraints(minHeight: 33.1.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.mainTeal : AppColors.permissionIconBg,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: isSelected ? AppColors.mainTeal : AppColors.iconBlueBorder),
          ),
          // Centered in that height; a heightFactor keeps the chip from filling
          // whatever height it is offered.
          child: Center(
            heightFactor: 1,
            child: Text(
              label,
              style: isSelected
                  ? AppTextStyles.pharmacyFilterChipSelected
                  : AppTextStyles.pharmacyFilterChip,
            ),
          ),
        ),
      ),
    );
  }
}
