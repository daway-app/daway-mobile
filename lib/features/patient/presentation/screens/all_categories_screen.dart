import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/category.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_state.dart';
import '../widgets/category_icon.dart';
import '../widgets/patient_bottom_nav_bar.dart';
import '../widgets/patient_dashboard_tab_scope.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CategoriesCubit>(),
      child: const _AllCategoriesView(),
    );
  }
}

class _AllCategoriesView extends StatelessWidget {
  const _AllCategoriesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: PatientBottomNavBar(
        selectedTab: PatientDashboardTab.home,
        onTabSelected: (tab) {
          Navigator.of(context).pop();
          PatientDashboardTabScope.maybeOf(context)?.switchToTab(tab);
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 32.h),
            Padding(
              padding: EdgeInsets.only(right: 24.w),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 42.w,
                    height: 42.w,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.accountIconBg,
                      border: Border.all(color: AppColors.iconBlueBorder),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/back_icon.svg',
                      colorFilter: const ColorFilter.mode(
                        AppColors.mainTeal,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'كل احتياجاتك في مكان واحد',
                textAlign: TextAlign.right,
                style: AppTextStyles.allCategoriesTitle,
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'اختر القسم المناسب وابدأ بالاستكشاف',
                textAlign: TextAlign.right,
                style: AppTextStyles.allCategoriesSubtitle,
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: BlocBuilder<CategoriesCubit, CategoriesState>(
                builder: (context, state) {
                  return switch (state) {
                    CategoriesLoading() => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    CategoriesLoadFailure(:final message) => Center(
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.homePharmacyCardSubtitle,
                        ),
                      ),
                    CategoriesLoaded(:final categories)
                        when categories.isEmpty =>
                      Center(
                        child: Text(
                          'لا توجد أقسام متاحة حالياً',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.homePharmacyCardSubtitle,
                        ),
                      ),
                    CategoriesLoaded(:final categories) =>
                      _AllCategoriesGrid(categories: categories),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllCategoriesGrid extends StatelessWidget {
  final List<Category> categories;

  const _AllCategoriesGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 24.h,
        childAspectRatio: 115 / 110,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return _AllCategoryCard(
          category: category,
          onTap: () => Navigator.of(context)
              .pushNamed(Routes.categoryMedicinesScreen, arguments: category),
        );
      },
    );
  }
}

class _AllCategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const _AllCategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.accountIconBg,
          border: Border.all(color: AppColors.iconBlueBorder),
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.only(top: 8.h, right: 8.w, left: 4.w, bottom: 4.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              category.nameAr,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.homeCategoryLabel,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: CategoryIcon(category: category),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
