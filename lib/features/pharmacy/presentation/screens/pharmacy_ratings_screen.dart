import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../cubit/pharmacy_ratings_cubit.dart';
import '../cubit/pharmacy_ratings_state.dart';
import '../helpers/notifications_navigation.dart';
import '../widgets/pharmacy_side_menu.dart';
import '../widgets/rating_card.dart';
import '../widgets/ratings_summary_card.dart';

class PharmacyRatingsScreen extends StatelessWidget {
  const PharmacyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'التقييمات والمراجعات',
          style: AppTextStyles.screenTitle.copyWith(
            color: AppColors.mainTeal,
            fontSize: 20.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: AppColors.mainTeal),
            onPressed: () => openNotifications(context),
          ),
        ],
      ),
      drawer: const PharmacySideMenu(),
      body: SafeArea(
        child: BlocBuilder<PharmacyRatingsCubit, PharmacyRatingsState>(
          builder: (context, state) {
            return switch (state) {
              PharmacyRatingsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              PharmacyRatingsLoadFailure(:final message) => ProfileLoadError(
                message: message,
                onRetry: () => context.read<PharmacyRatingsCubit>().load(),
              ),
              PharmacyRatingsLoaded() => _buildLoaded(context, state),
            };
          },
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, PharmacyRatingsLoaded state) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'آراء عملائنا تساعدنا على تقديم أفضل خدمة',
                style: AppTextStyles.cardDescription,
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 16.h),
              RatingsSummaryCard(
                averageRating: state.averageRating,
                totalCount: state.totalCount,
                starCounts: state.starCounts,
              ),
              SizedBox(height: 20.h),
              Text(
                'أحدث المراجعات',
                style: AppTextStyles.cardTitle.copyWith(fontSize: 16.sp),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        Expanded(
          child: state.ratings.isEmpty
              ? Center(
                  child: Text(
                    'لا توجد مراجعات بعد',
                    style: AppTextStyles.cardDescription,
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                  itemCount: state.ratings.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) =>
                      RatingCard(rating: state.ratings[index]),
                ),
        ),
      ],
    );
  }
}
