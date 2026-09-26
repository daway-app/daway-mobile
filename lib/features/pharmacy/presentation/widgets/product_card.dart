import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/price_formatter.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/medicine.dart';
import '../helpers/medicine_text_display.dart';
import 'product_quantity_stepper.dart';
import 'product_status_badge.dart';

/// One medicine on the products page: its picture, name, active ingredient and
/// price, the stock badge, and the stepper that changes the quantity.
///
/// [quantity] and [status] are passed in rather than read off [medicine]: while
/// a stepper tap is still being saved, the page shows the quantity the
/// pharmacist asked for.
class ProductCard extends StatelessWidget {
  final Medicine medicine;
  final int quantity;
  final MedicineStatus status;
  final VoidCallback onTap;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ProductCard({
    super.key,
    required this.medicine,
    required this.quantity,
    required this.status,
    required this.onTap,
    required this.onIncrement,
    required this.onDecrement,
  });

  static const double _imageSize = 62;
  static const double _imageInset = 8;
  static const double _imageGap = 12;

  @override
  Widget build(BuildContext context) {
    final name = medicine.displayName;
    final ingredient = medicine.activeIngredient;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 106.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Stack(
          children: [
            // The picture is centered on the card's own height, whatever the
            // text beside it comes to.
            Positioned.fill(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: _imageInset.w),
                  child: _ProductImage(imageUrl: medicine.imageUrl),
                ),
              ),
            ),
            Padding(
              // The stepper's touch area reaches above and below what it draws,
              // so it takes over that much of the gap above it and of the
              // padding under it.
              padding: EdgeInsetsDirectional.fromSTEB(
                (_imageInset + _imageSize + _imageGap).w,
                12.h,
                12.w,
                (12 - ProductQuantityStepper.touchReach).h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          textDirection: textDirectionFor(name),
                          style: AppTextStyles.pharmacyProductName,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      ProductStatusBadge(status: status),
                    ],
                  ),
                  if (ingredient != null && ingredient.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      // Catalog ingredients often arrive all-caps from an
                      // import; see [isShoutyLatinName].
                      isShoutyLatinName(ingredient) ? ingredient.toLowerCase() : ingredient,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      textDirection: textDirectionFor(ingredient),
                      style: AppTextStyles.pharmacyProductIngredient,
                    ),
                  ],
                  // The price is 14 under the ingredient; the stepper is taller
                  // than it, and centered on it.
                  SizedBox(height: (12.5 - ProductQuantityStepper.touchReach).h),
                  Row(
                    children: [
                      Expanded(child: _Price(price: medicine.price)),
                      ProductQuantityStepper(
                        quantity: quantity,
                        onIncrement: onIncrement,
                        onDecrement: onDecrement,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "₪ 18": in the right-to-left line the shekel sign comes first, so it stands
/// to the right of the amount.
class _Price extends StatelessWidget {
  final double price;

  const _Price({required this.price});

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.pharmacyProductPrice;
    return Text(
      '₪ ${formatPrice(price)}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
      // The sign is drawn from another font, whose taller line would push the
      // row down.
      strutStyle: StrutStyle.fromTextStyle(style, forceStrutHeight: true),
      style: style,
    );
  }
}

/// The medicine's picture — or, without one, the empty tinted frame it would
/// sit in.
class _ProductImage extends StatelessWidget {
  final String? imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return Container(
      width: ProductCard._imageSize.w,
      height: ProductCard._imageSize.w,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.permissionIconBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.iconBlueBorder),
      ),
      child: (url == null || url.isEmpty)
          ? null
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
    );
  }
}
