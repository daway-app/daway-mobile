import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../domain/entities/onboarding_page.dart';
import 'onboarding_availability_illustration.dart';
import 'onboarding_indicator.dart';
import 'onboarding_next_button.dart';

class OnboardingPageContent extends StatelessWidget {
  final OnboardingPage page;
  final int pageCount;
  final int currentIndex;
  final bool isLast;
  final VoidCallback onActionPressed;

  const OnboardingPageContent({
    super.key,
    required this.page,
    required this.pageCount,
    required this.currentIndex,
    required this.isLast,
    required this.onActionPressed,
  });

  Widget _buildIllustration() {
    switch (page.illustrationStyle) {
      case OnboardingIllustrationStyle.circleBadge:
        return Align(
          alignment: Alignment.center,
          child: page.illustrationAsset != null
              ? SvgPicture.asset(
                  page.illustrationAsset!,
                  width: 230.w,
                  height: 230.w,
                )
              : const OnboardingAvailabilityIllustration(),
        );
      case OnboardingIllustrationStyle.bleedCard:
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: SizedBox(
              width: double.infinity,
              child: SvgPicture.asset(
                page.illustrationAsset!,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 32.h),
        Expanded(flex: 2, child: _buildIllustration()),
        Expanded(
          flex: 3,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final titleTopClearance = constraints.maxHeight * 0.35 + 24.h;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: 1 - page.backgroundTopInset,
                      widthFactor: 1,
                      child: Image.asset(
                        page.backgroundAsset,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      24.w,
                      titleTopClearance,
                      24.w,
                      24.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          page.title,
                          textAlign: TextAlign.start,
                          style: AppTextStyles.screenTitle.copyWith(
                            color: Colors.white,
                            fontSize: 24.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.start,
                          style: AppTextStyles.authSubtitle.copyWith(
                            fontSize: 18.sp,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const Spacer(),
                        isLast
                            ? Row(
                                children: [
                                  OnboardingIndicator(
                                    count: pageCount,
                                    currentIndex: currentIndex,
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: AppCustomButton(
                                      text: 'ابدأ الآن',
                                      backgroundColor: Colors.white,
                                      textColor: AppColors.mainTeal,
                                      onPressed: onActionPressed,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  OnboardingIndicator(
                                    count: pageCount,
                                    currentIndex: currentIndex,
                                  ),
                                  OnboardingNextButton(
                                    onPressed: onActionPressed,
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
