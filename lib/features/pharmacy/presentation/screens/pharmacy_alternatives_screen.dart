import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../../domain/entities/medicine.dart';
import '../cubit/pharmacy_alternatives_cubit.dart';
import '../cubit/pharmacy_alternatives_state.dart';
import '../helpers/medicine_text_display.dart';
import '../widgets/alternative_candidate_card.dart';
import '../widgets/medicine_status_badge.dart';

class PharmacyAlternativesScreen extends StatelessWidget {
  const PharmacyAlternativesScreen({super.key});

  Future<void> _toggleCandidate(
    BuildContext context,
    Medicine candidate,
  ) async {
    final error = await context
        .read<PharmacyAlternativesCubit>()
        .toggleCandidate(candidate);
    if (error != null && context.mounted) {
      AppSnackbar.show(context, error);
    }
  }

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
          'البدائل',
          style: AppTextStyles.screenTitle.copyWith(
            color: AppColors.mainTeal,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: SafeArea(
        child:
            BlocBuilder<PharmacyAlternativesCubit, PharmacyAlternativesState>(
              builder: (context, state) {
                return switch (state) {
                  PharmacyAlternativesLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  PharmacyAlternativesLoadFailure(:final message) =>
                    ProfileLoadError(
                      message: message,
                      onRetry: () =>
                          context.read<PharmacyAlternativesCubit>().load(),
                    ),
                  PharmacyAlternativesLoaded() => _buildLoaded(context, state),
                };
              },
            ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, PharmacyAlternativesLoaded state) {
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        _BaseMedicineBanner(medicine: state.baseMedicine),
        SizedBox(height: 20.h),
        Text(
          'بدائل بنفس المادة الفعالة',
          style: AppTextStyles.cardTitle.copyWith(fontSize: 16.sp),
          textAlign: TextAlign.right,
        ),
        SizedBox(height: 12.h),
        if (state.candidates.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Text(
              'لا توجد أدوية أخرى بنفس المادة الفعالة في مخزونك',
              textAlign: TextAlign.center,
              style: AppTextStyles.cardDescription,
            ),
          )
        else
          for (final candidate in state.candidates) ...[
            AlternativeCandidateCard(
              candidate: candidate,
              isSelected: state.selectedAlternativeIds.contains(
                candidate.medicineId,
              ),
              isUpdating: state.updatingCandidateId == candidate.id,
              // Only the tapped card's own button disables itself while
              // *any* update is in flight — the rest go null (disabled but
              // no spinner) so a second tap can't race the first.
              onTap: state.updatingCandidateId == null
                  ? () => _toggleCandidate(context, candidate)
                  : null,
            ),
            SizedBox(height: 12.h),
          ],
      ],
    );
  }
}

class _BaseMedicineBanner extends StatelessWidget {
  final Medicine medicine;

  const _BaseMedicineBanner({required this.medicine});

  String get _statusLabel => switch (medicine.status) {
    MedicineStatus.outOfStock => 'غير متوفر حالياً',
    MedicineStatus.low => 'مخزون منخفض',
    MedicineStatus.available => 'متوفر',
  };

  IconData get _statusIcon => switch (medicine.status) {
    MedicineStatus.outOfStock => Icons.warning_amber_rounded,
    MedicineStatus.low => Icons.warning_amber_rounded,
    MedicineStatus.available => Icons.check_circle_outline,
  };

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabel;
    final color = colorForMedicineStatus(medicine.status);
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconBadge(icon: _statusIcon, color: color, size: 40),
              const Spacer(),
              Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            medicine.displayName,
            textAlign: TextAlign.center,
            textDirection: textDirectionFor(medicine.displayName),
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          if (medicine.activeIngredient != null &&
              medicine.activeIngredient!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              medicine.activeIngredient!,
              textAlign: TextAlign.center,
              textDirection: textDirectionFor(medicine.activeIngredient!),
              style: TextStyle(fontSize: 13.sp, color: AppColors.grey),
            ),
          ],
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الكمية المتوفرة:',
                style: TextStyle(fontSize: 13.sp, color: AppColors.grey),
              ),
              Text(
                '${medicine.quantity}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
