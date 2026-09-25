import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../domain/entities/onboarding_page.dart';
import 'onboarding_indicator.dart';

class OnboardingPageContent extends StatelessWidget {
  final OnboardingPage page;
  final int pageCount;
  final int currentIndex;
  final bool isLast;
  final VoidCallback onActionPressed;
  final VoidCallback onSkipPressed;

  const OnboardingPageContent({
    super.key,
    required this.page,
    required this.pageCount,
    required this.currentIndex,
    required this.isLast,
    required this.onActionPressed,
    required this.onSkipPressed,
  });

  @override
  Widget build(BuildContext context) {
    // The action button (and skip link) sit in a fixed block below the
    // scrollable content instead of a fixed-height spacer, so they stay
    // right under the content on every screen size instead of being
    // pushed toward the bottom edge by a magic-number gap.
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 60.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 37.w),
                  child: page.illustrationAsset != null
                      ? Image.asset(
                          page.illustrationAsset!,
                          height: 230.h,
                          fit: BoxFit.contain,
                        )
                      : _IllustrationPlaceholder(),
                ),
                SizedBox(height: 40.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 37.w),
                  child: Column(
                    children: [
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.onboardingTitle,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        page.subtitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.onboardingSubtitle,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                OnboardingIndicator(count: pageCount, currentIndex: currentIndex),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: AppCustomButton(
            text: isLast ? 'ابدأ الآن' : 'التالي',
            onPressed: onActionPressed,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (isLast)
          SizedBox(height: 24.h)
        else ...[
          // 10 of space plus the link's own 14 of vertical padding is the
          // design's 24 of visible space above and below "تخطي" — while the
          // tap target stays 44 tall instead of shrinking to the text line.
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: onSkipPressed,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: Text('تخطي', textAlign: TextAlign.center, style: AppTextStyles.onboardingSkip),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ],
    );
  }
}

/// Shown instead of the real illustration until design delivers the final
/// artwork for this onboarding page.
class _IllustrationPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230.h,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accountIconBg,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.iconBlueBorder, width: 1.0),
      ),
      child: Icon(
        Icons.image_outlined,
        size: 64.sp,
        color: AppColors.primaryTeal,
      ),
    );
  }
}
