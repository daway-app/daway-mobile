import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/category_subcategory.dart';

/// "بماذا تشعر" grid on the medicines category screen — one card per
/// symptom subcategory (`group_key == 'symptoms'`), styled like the
/// category cards on the home/all-categories grids. The backend doesn't
/// return an illustration per subcategory, so the artwork is bundled in
/// `assets/images/` and looked up by slug.
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
        padding: EdgeInsets.only(top: 8.h, right: 8.w, left: 4.w, bottom: 9.h),
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
                child: _SymptomImage(slug: symptom.slug),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Same size as [CategoryIcon] so these cards match the category grid.
class _SymptomImage extends StatelessWidget {
  final String slug;

  const _SymptomImage({required this.slug});

  @override
  Widget build(BuildContext context) {
    final asset = _symptomAssets[slug];
    if (asset == null) {
      return Icon(Icons.medical_information_outlined, size: 56.sp, color: AppColors.mainTeal);
    }
    return Image.asset(
      asset,
      width: 62.w,
      height: 62.w,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.medical_information_outlined, size: 56.sp, color: AppColors.mainTeal),
    );
  }
}

/// Bundled illustrations for the symptom subcategories the backend sends
/// today. A symptom with no entry here falls back to a generic icon.
const Map<String, String> _symptomAssets = {
  'cough-sore-throat': 'assets/images/cough_sore_throat.png',
  'cold-flu': 'assets/images/cold_flu.png',
  'pain-headache': 'assets/images/headache.png',
  'stomach-care': 'assets/images/stomach_problems.png',
  'allergy': 'assets/images/allergy.png',
  'fever-temperature': 'assets/images/fever.png',
};
