import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/smart_date_formatter.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../domain/entities/rating.dart';

class RatingCard extends StatelessWidget {
  final Rating rating;

  const RatingCard({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final comment = rating.comment;
    return AppCard(
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InitialsAvatar(name: rating.patientName),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      rating.patientName,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.personName,
                    ),
                    SizedBox(height: 4.h),
                    StarRating(rating: rating.stars.toDouble(), size: 14),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                smartDate(rating.createdAt),
                style: TextStyle(fontSize: 11.sp, color: AppColors.grey),
              ),
            ],
          ),
          if (comment != null && comment.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              comment,
              textAlign: TextAlign.right,
              style: AppTextStyles.cardDescription,
            ),
          ],
        ],
      ),
    );
  }
}
