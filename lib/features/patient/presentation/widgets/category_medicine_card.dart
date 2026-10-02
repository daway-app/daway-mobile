import 'package:flutter/material.dart';

import '../../domain/entities/category_medicine.dart';
import 'medicine_grid_card.dart';

/// A medicine card for a category's results grid: the medicine's image when
/// the backend sends one (a stand-in icon otherwise), its name, and its
/// generic name / dosage form.
class CategoryMedicineCard extends StatelessWidget {
  final CategoryMedicine medicine;
  final VoidCallback onDetailsTap;

  const CategoryMedicineCard({
    super.key,
    required this.medicine,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryLine = medicine.genericName?.isNotEmpty == true
        ? medicine.genericName
        : medicine.dosageForm;
    final imageUrl = medicine.imageUrl;

    return MedicineGridCard(
      media: (imageUrl != null && imageUrl.isNotEmpty)
          ? Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const MedicinePlaceholderIcon(),
            )
          : const MedicinePlaceholderIcon(),
      title: medicine.tradeName,
      subtitle: secondaryLine,
      detailsLabel: 'عرض تفاصيل',
      onDetailsTap: onDetailsTap,
    );
  }
}
