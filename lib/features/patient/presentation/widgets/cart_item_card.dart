import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/price_formatter.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/cart_item.dart';

/// One row in "السلة" — the medicine/pharmacy line, its price, and a
/// quantity stepper. No per-line delete here (the design has none): the
/// minus button just stops at a quantity of 1 (see CartCubit.decrementQuantity).
class CartItemCard extends StatelessWidget {
  final CartItem item;
  final bool isUpdating;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CartItemCard({
    super.key,
    required this.item,
    required this.isUpdating,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 74.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          _Thumbnail(imageUrl: item.medicineImageUrl),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: item.medicineName, style: AppTextStyles.cartItemName),
                      TextSpan(
                        text: '/ ${item.pharmacyName}',
                        style: AppTextStyles.cartItemPharmacyName,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Text(
                  '${formatPrice(item.price)} \$/الشريط',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.cartItemPrice,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          _StepperButton(
            icon: Icons.remove,
            filled: false,
            onTap: isUpdating ? null : onDecrement,
          ),
          SizedBox(width: 4.w),
          SizedBox(
            width: 24.w,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: AppTextStyles.cartQuantity,
            ),
          ),
          SizedBox(width: 4.w),
          _StepperButton(
            icon: Icons.add,
            filled: true,
            onTap: isUpdating ? null : onIncrement,
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String? imageUrl;

  const _Thumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return Container(
      width: 48.w,
      height: 48.w,
      padding: EdgeInsetsDirectional.only(start: 6.w, end: 4.w),
      decoration: BoxDecoration(
        color: AppColors.permissionIconBg,
        border: Border.all(color: AppColors.iconBlueBorder),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: (url != null && url.isNotEmpty)
          ? Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.medication_outlined,
                size: 20.sp,
                color: AppColors.mainTeal,
              ),
            )
          : Icon(Icons.medication_outlined, size: 20.sp, color: AppColors.mainTeal),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, required this.filled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = (filled ? 26.67 : 27).w;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? AppColors.mainTeal : AppColors.permissionIconBg,
            border: filled ? null : Border.all(color: AppColors.iconBlueBorder),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Icon(icon, size: 14.sp, color: filled ? Colors.white : AppColors.mainTeal),
        ),
      ),
    );
  }
}
