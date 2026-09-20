import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/category_subcategory.dart';

/// "بماذا تشعر" grid on the medicines category screen — one card per
/// symptom subcategory (`group_key == 'symptoms'`), styled like the
/// category cards on the home/all-categories grids. The backend doesn't
/// return an illustration per subcategory, so this falls back to a
/// stand-in Material icon, same as [CategoryIcon] does for categories.
class CategorySymptomGrid extends StatelessWidget {
  final List<CategorySubcategory> symptoms;
  final ValueChanged<CategorySubcategory> onSymptomTap;

  const CategorySymptomGrid({
    super.key,
    required this.symptoms,
    required this.onSymptomTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: symptoms.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 114 / 110,
      ),
      itemBuilder: (context, index) {
        final symptom = symptoms[index];
        return _SymptomCard(symptom: symptom, onTap: () => onSymptomTap(symptom));
      },
    );
  }
}

class _SymptomCard extends StatelessWidget {
  final CategorySubcategory symptom;
  final VoidCallback onTap;

  const _SymptomCard({required this.symptom, required this.onTap});

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
              symptom.nameAr,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.homeCategoryLabel,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Icon(iconForSymptomSlug(symptom.slug), size: 40.sp, color: AppColors.mainTeal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Maps a symptom subcategory slug to a stand-in Material icon — used until
/// the backend has real illustrations for these (see class doc comment).
IconData iconForSymptomSlug(String slug) {
  return switch (slug) {
    'cough-sore-throat' => Icons.sick_outlined,
    'cold-flu' => Icons.ac_unit_rounded,
    'pain-headache' => Icons.psychology_alt_outlined,
    'stomach-care' => Icons.emoji_food_beverage_outlined,
    'allergy' => Icons.air_rounded,
    'fever-temperature' => Icons.thermostat_rounded,
    _ => Icons.medical_information_outlined,
  };
}
