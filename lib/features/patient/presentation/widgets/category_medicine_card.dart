import 'package:flutter/material.dart';

import '../../domain/entities/category_medicine.dart';
import 'medicine_grid_card.dart';

/// A medicine card for a category's results grid.
///
/// The backend's category-medicines list doesn't return a per-medicine image
/// or a "متوفر في N صيدليات" pharmacy count (see `GET
/// /categories/{slug}/medicines`) — this shows a stand-in icon and the
/// medicine's dosage form/generic name instead until the backend adds those
/// fields.
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

    return MedicineGridCard(
      media: const MedicinePlaceholderIcon(),
      title: medicine.tradeName,
      subtitle: secondaryLine,
      detailsLabel: 'عرض تفاصيل',
      onDetailsTap: onDetailsTap,
    );
  }
}
