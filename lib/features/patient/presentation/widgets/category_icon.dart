import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../domain/entities/category.dart';

/// Shows the category's real artwork ([Category.image], a Cloudinary URL)
/// when the backend has one, falling back to a stand-in Material icon —
/// either because this category has none yet, or the image fails to load.
/// Shared by the home grid and the "all categories" screen.
class CategoryIcon extends StatelessWidget {
  final Category category;

  const CategoryIcon({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final image = category.image;
    if (image == null || image.isEmpty) {
      return Icon(iconForCategorySlug(category.slug), size: 56.sp, color: AppColors.mainTeal);
    }
    return Image.network(
      image,
      width: 62.w,
      height: 62.w,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          Icon(iconForCategorySlug(category.slug), size: 58.sp, color: AppColors.mainTeal),
    );
  }
}

/// Maps a category slug to a stand-in Material icon — used only when the
/// backend hasn't set [Category.image] for this category, or the image
/// fails to load (see [CategoryIcon]).
IconData iconForCategorySlug(String slug) {
  return switch (slug) {
    'medicines' => Icons.medication_rounded,
    'dental-care' => Icons.health_and_safety_rounded,
    'first-aid' => Icons.medical_services_rounded,
    'skin-care-beauty' => Icons.spa_rounded,
    'vitamins-supplements' => Icons.eco_rounded,
    'medical-supplies' => Icons.local_hospital_rounded,
    _ => Icons.category_rounded,
  };
}
