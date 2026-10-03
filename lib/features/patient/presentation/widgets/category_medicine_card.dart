import 'package:flutter/material.dart';

import '../../../../core/theming/app_colors.dart';
import '../../domain/entities/category_medicine.dart';
import '../helpers/pharmacy_availability_label.dart';
import 'medicine_grid_card.dart';

/// A medicine card for a category's results grid: the medicine's image when
/// there is one (a stand-in icon otherwise), its name, and how many pharmacies
/// stock it (or its generic name / dosage form when that isn't known).
class CategoryMedicineCard extends StatelessWidget {
  final CategoryMedicine medicine;
  final VoidCallback onDetailsTap;

  /// An image resolved elsewhere (the listing itself has none); used when the
  /// medicine carries no image of its own.
  final String? resolvedImageUrl;

  const CategoryMedicineCard({
    super.key,
    required this.medicine,
    required this.onDetailsTap,
    this.resolvedImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryLine = medicine.genericName?.isNotEmpty == true
        ? medicine.genericName
        : medicine.dosageForm;
    final imageUrl = medicine.imageUrl ?? resolvedImageUrl;
    final pharmaciesCount = medicine.pharmaciesCount;

    return MedicineGridCard(
      media: (imageUrl != null && imageUrl.isNotEmpty)
          ? Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const MedicinePlaceholderIcon(),
            )
          : const MedicinePlaceholderIcon(),
      title: medicine.tradeName,
      // The availability line like the search cards when the API says how
      // many pharmacies stock it; otherwise the generic name / dosage form.
      subtitle: pharmaciesCount == null
          ? secondaryLine
          : (pharmaciesCount > 0
              ? pharmaciesAvailabilityLabel(pharmaciesCount)
              : 'غير متوفر حالياً'),
      subtitleColor: pharmaciesCount == null
          ? null
          : (pharmaciesCount > 0 ? AppColors.success : AppColors.grey),
      detailsLabel: 'عرض تفاصيل',
      onDetailsTap: onDetailsTap,
    );
  }
}
