import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

/// One of the two outlined action cards under the filters ("أضف منتج جديد",
/// "تحديث المنتجات"): a label with a plus after it, centered in a 56px card.
/// Fills the width it is given, so a row of two shares it.
class ProductActionCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const ProductActionCard({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: label,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: 56.h),
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.iconBlueBorder),
          ),
          // Centered both ways in the card; a heightFactor keeps the card
          // from growing to fill whatever height it is offered.
          child: Center(
            heightFactor: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.pharmacyActionCardLabel,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.add, size: 24.w, color: AppColors.mainTeal),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
