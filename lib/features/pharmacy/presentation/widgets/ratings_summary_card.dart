import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/star_rating.dart';
import 'rating_star_bar.dart';

/// The average-rating number alongside the 5→1 star breakdown bars, at the
/// top of the التقييمات والمراجعات screen. Laid out left-to-right regardless
/// of the app's Arabic locale (`textDirection: TextDirection.ltr`) — this is
/// a fixed chart layout, not flowing text, so it stays pinned to the
/// designed "number on the left, bars on the right" arrangement.
class RatingsSummaryCard extends StatelessWidget {
  final double averageRating;
  final int totalCount;
  final Map<int, int> starCounts;

  const RatingsSummaryCard({
    super.key,
    required this.averageRating,
    required this.totalCount,
    required this.starCounts,
  });

  @override
  Widget build(BuildContext context) {
    final maxCount = starCounts.values.isEmpty
        ? 0
        : starCounts.values.reduce((a, b) => a > b ? a : b);
    // Rounded once so the displayed number and the star icons below it never
    // disagree (e.g. an unrounded 4.97 would print "5.0" next to 4.5 stars).
    final roundedAverage =
        double.parse(averageRating.toStringAsFixed(1));

    return AppCard(
      padding: EdgeInsets.all(20.r),
      child: Row(
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100.w,
            child: Column(
              children: [
                Text(
                  roundedAverage.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainTeal,
                  ),
                ),
                Text(
                  'من 5',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.grey),
                ),
                SizedBox(height: 6.h),
                StarRating(rating: roundedAverage, size: 16),
                SizedBox(height: 6.h),
                Text(
                  '$totalCount تقييمًا',
                  style: TextStyle(fontSize: 11.sp, color: AppColors.grey),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 130.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            color: AppColors.borderGrey,
          ),
          Expanded(
            child: Column(
              children: [
                for (final stars in [5, 4, 3, 2, 1])
                  RatingStarBar(
                    stars: stars,
                    count: starCounts[stars] ?? 0,
                    maxCount: maxCount,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
