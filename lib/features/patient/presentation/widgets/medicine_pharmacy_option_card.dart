import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/price_formatter.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/medicine_pharmacy_offer.dart';

/// One selectable row in "اختر الصيدلية المناسبة لك" — a radio-style choice,
/// not a navigation target, so selection is the screen's own local UI state
/// (CLAUDE.md B1: setState is for exactly this — a toggle — not a cubit).
class MedicinePharmacyOptionCard extends StatelessWidget {
  final MedicinePharmacyOffer offer;
  final bool selected;
  final VoidCallback onTap;

  const MedicinePharmacyOptionCard({
    super.key,
    required this.offer,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final distanceKm = offer.distanceKm;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // The design gives the selected card 61 and the unselected one 63 —
        // kept as given even though that reads as a rounding slip, per
        // figma-screen-workflow's "follow the majority" precedent. A
        // `minHeight`, not a fixed `height`: three lines of real text (a
        // long pharmacy name's distance/price, or a larger system font
        // scale) can need a hair more room than 61/63 gives, and clipping
        // that is worse than the card growing past the spec by a few px.
        constraints: BoxConstraints(minHeight: (selected ? 61 : 63).h),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: selected ? AppColors.permissionIconBg : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.iconBlueBorder : AppColors.productDetailCardBorder,
            width: selected ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            _PharmacyThumbnail(imageUrl: offer.imageUrl),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Distance sits on the same line, right after the name.
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          offer.pharmacyName,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.medicinePharmacyName,
                        ),
                      ),
                      if (distanceKm != null) ...[
                        SizedBox(width: 8.w),
                        Text(
                          'يبعد عنك ${distanceKm.toStringAsFixed(1)} كيلو',
                          style: AppTextStyles.medicinePharmacyDistance,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${formatPrice(offer.price)} \$/الشريط',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.medicinePharmacyPrice,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            _RadioIndicator(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _PharmacyThumbnail extends StatelessWidget {
  final String? imageUrl;

  const _PharmacyThumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return Container(
      width: 45.w,
      height: 45.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.thumbnailBackground,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: (url != null && url.isNotEmpty)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                width: 45.w,
                height: 45.w,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.local_pharmacy_outlined,
                  size: 20.sp,
                  color: AppColors.grey,
                ),
              ),
            )
          // `GET /medicines/{id}/pharmacies` has no logo/photo field today
          // (see MedicinePharmacyOffer.imageUrl), so this is always the
          // placeholder for now.
          : Icon(Icons.local_pharmacy_outlined, size: 20.sp, color: AppColors.grey),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  final bool selected;

  const _RadioIndicator({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.mainTeal : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.iconBlueBorder : AppColors.productDetailCardBorder,
          width: 2,
        ),
      ),
    );
  }
}
