import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/category.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_state.dart';
import 'category_icon.dart';
import 'home_section_header.dart';

/// How many categories the home grid shows — matches the design's 3x2 grid;
/// the rest are reachable through "عرض الكل".
const int _homeCategoriesLimit = 6;

class HomeCategoriesSection extends StatelessWidget {
  final VoidCallback onViewAllTap;
  final ValueChanged<Category> onCategoryTap;

  const HomeCategoriesSection({
    super.key,
    required this.onViewAllTap,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(title: 'الاقسام', onViewAllTap: onViewAllTap),
        SizedBox(height: 16.h),
        BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, state) {
            return switch (state) {
              CategoriesLoading() => SizedBox(
                  height: 110.h,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              CategoriesLoadFailure(:final message) => SizedBox(
                  height: 110.h,
                  child: Center(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.homePharmacyCardSubtitle,
                    ),
                  ),
                ),
              CategoriesLoaded(:final categories) when categories.isEmpty => SizedBox(
                  height: 110.h,
                  child: Center(
                    child: Text(
                      'لا توجد أقسام متاحة حالياً',
                      textAlign: TextAlign.center,

                      style: AppTextStyles.homePharmacyCardSubtitle,
                    ),
                  ),
                ),
              CategoriesLoaded(:final categories) => _CategoryGrid(
                  categories: categories.take(_homeCategoriesLimit).toList(),
                  onCategoryTap: onCategoryTap,
                ),
            };
          },
        ),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<Category> categories;
  final ValueChanged<Category> onCategoryTap;

  const _CategoryGrid({required this.categories, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 114 / 110,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryCard(category: category, onTap: () => onCategoryTap(category));
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

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
