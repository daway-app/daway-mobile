import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/helpers/price_formatter.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/favorite_medicine.dart';
import '../helpers/pharmacy_availability_label.dart';

/// A saved medicine in "الأدوية المحفوظة". The enriched favorites response
/// has no dosage/strength field (unlike the design's "500 مجم" chip), so
/// that chip isn't modeled here — add it back once the backend returns one.
class FavoriteMedicineCard extends StatelessWidget {
  final FavoriteMedicine medicine;
  final VoidCallback onCompareTap;

  const FavoriteMedicineCard({
    super.key,
    required this.medicine,
    required this.onCompareTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = medicine.imageUrl;
    final showEnglishName =
        medicine.tradeNameAr != null && medicine.tradeNameAr!.isNotEmpty;
    final hasPharmacies = medicine.isAvailable && medicine.pharmaciesCount > 0;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // RTL order (first child is rightmost): thumbnail on the right edge,
          // the names beside it to its left, as in the design.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.thumbnailBackground,
                  border: Border.all(color: AppColors.thumbnailBorder, width: 1.05),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(7.r),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.medication_outlined,
                            size: 24.sp,
                            color: AppColors.grey,
                          ),
                        ),
                      )
                    : Icon(Icons.medication_outlined, size: 24.sp, color: AppColors.grey),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  // `start`, not `end`: this app is RTL, so `start` is the
                  // right edge, where the names sit next to the thumbnail.
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.displayName,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.favoriteCardName,
                    ),
                    if (showEnglishName) ...[
                      SizedBox(height: 4.h),
                      Text(
                        medicine.tradeName,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.mutedCaption,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.permissionIconBg,
              border: Border.all(color: AppColors.iconBlueBorder, width: 1.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                SvgPicture.asset('assets/icons/home_fill_icon.svg', width: 20.w, height: 20.w),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    hasPharmacies
                        ? pharmaciesAvailabilityLabel(medicine.pharmaciesCount)
                        : 'غير متوفر حالياً',
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.favoriteCardAvailability,
                  ),
                ),
                if (medicine.minPrice != null) ...[
                  Text('يبدأ من ', style: AppTextStyles.favoriteCardPriceLabel),
                  Text(
                    '${formatPrice(medicine.minPrice!)} ₪',
                    style: AppTextStyles.favoriteCardPrice,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 56.h,
            child: ElevatedButton(
              onPressed: onCompareTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/icons/price_comparison.svg', width: 14.w, height: 14.w),
                  SizedBox(width: 6.w),
                  Text(
                    'مقارنة الأسعار',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
