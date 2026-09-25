import 'package:flutter/material.dart';

import '../../../../core/theming/app_colors.dart';
import '../../domain/entities/searched_medicine.dart';
import '../helpers/pharmacy_availability_label.dart';
import 'medicine_grid_card.dart';

/// A medicine card for the search results grid — unlike
/// [CategoryMedicineCard], `GET /medicines/search` does return a real image
/// and a live "متوفر في N صيدليات" count, so this shows both instead of a
/// stand-in icon.
class SearchedMedicineCard extends StatelessWidget {
  final SearchedMedicine medicine;
  final VoidCallback onDetailsTap;

  const SearchedMedicineCard({
    super.key,
    required this.medicine,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = medicine.imageUrl;
    final hasPharmacies = medicine.isAvailable && medicine.availablePharmaciesCount > 0;

    return MedicineGridCard(
      media: (imageUrl != null && imageUrl.isNotEmpty)
          ? Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const MedicinePlaceholderIcon(),
            )
          : const MedicinePlaceholderIcon(),
      title: medicine.tradeName,
      subtitle: hasPharmacies
          ? pharmaciesAvailabilityLabel(medicine.availablePharmaciesCount)
          : 'غير متوفر حالياً',
      subtitleColor: hasPharmacies ? AppColors.success : AppColors.grey,
      detailsLabel: 'عرض التفاصيل',
      onDetailsTap: onDetailsTap,
    );
  }
}
