import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/medicine.dart';
import '../helpers/medicine_text_display.dart';
import 'medicine_status_badge.dart';

/// Shared by both the selected and unselected candidate-action buttons, so
/// a padding/radius tweak only has to change in one place.
ButtonStyle get _buttonShape => ButtonStyle(
  padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 8.h)),
  shape: WidgetStateProperty.all(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
  ),
);

class AlternativeCandidateCard extends StatelessWidget {
  final Medicine candidate;
  final bool isSelected;
  final bool isUpdating;

  /// Null while a *different* candidate has a request in flight (the
  /// backend allows multiple simultaneous alternatives, so this app
  /// enforces "only one selected" client-side by blocking every other
  /// button until that request settles).
  final VoidCallback? onTap;

  const AlternativeCandidateCard({
    super.key,
    required this.candidate,
    required this.isSelected,
    required this.isUpdating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CandidateImage(imageUrl: candidate.imageUrl),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.displayName,
                      textAlign: TextAlign.right,
                      textDirection: textDirectionFor(candidate.displayName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mainTeal,
                      ),
                    ),
                    if (candidate.activeIngredient != null &&
                        candidate.activeIngredient!.isNotEmpty) ...[
                      SizedBox(height: 3.h),
                      Text(
                        candidate.activeIngredient!,
                        textAlign: TextAlign.right,
                        textDirection: textDirectionFor(
                          candidate.activeIngredient!,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.sell_outlined,
                          size: 13.sp,
                          color: AppColors.grey,
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            'السعر ${candidate.price.toStringAsFixed(2)} ${AppConstants.currencySuffix}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            // Button first (renders on the right, the RTL reading-start —
            // matching the reference design's primary action placement),
            // status badge last (renders on the left).
            children: [
              if (isUpdating)
                SizedBox(
                  width: 120.w,
                  height: 36.h,
                  child: const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: 140.w,
                  child: isSelected
                      ? ElevatedButton.icon(
                          onPressed: onTap,
                          style: _buttonShape.merge(
                            ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mainTeal,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('تم اختياره'),
                        )
                      : OutlinedButton(
                          onPressed: onTap,
                          style: _buttonShape.merge(
                            OutlinedButton.styleFrom(
                              foregroundColor: AppColors.mainTeal,
                              side: BorderSide(color: AppColors.mainTeal),
                            ),
                          ),
                          child: const Text('اختيار البديل'),
                        ),
                ),
              const Spacer(),
              MedicineStatusBadge(status: candidate.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _CandidateImage extends StatelessWidget {
  final String? imageUrl;

  const _CandidateImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.w,
      height: 56.w,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: (imageUrl != null && imageUrl!.isNotEmpty)
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.medication_outlined,
                color: AppColors.grey,
                size: 24.sp,
              ),
            )
          : Icon(Icons.medication_outlined, color: AppColors.grey, size: 24.sp),
    );
  }
}
