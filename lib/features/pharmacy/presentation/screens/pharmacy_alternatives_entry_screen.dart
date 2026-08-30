import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../domain/entities/medicine.dart';
import '../cubit/pharmacy_alternatives_medicines_cubit.dart';
import '../cubit/pharmacy_alternatives_medicines_state.dart';
import '../helpers/medicine_text_display.dart';
import '../widgets/medicine_status_badge.dart';

/// Entry point for "البدائل" from the side menu: every medicine in stock,
/// each showing whether it already has an alternative linked and whether it
/// still needs one — matching the pharmacy web dashboard's "إدارة البدائل"
/// page, which lists every medicine rather than only the ones running low.
class PharmacyAlternativesEntryScreen extends StatefulWidget {
  const PharmacyAlternativesEntryScreen({super.key});

  @override
  State<PharmacyAlternativesEntryScreen> createState() =>
      _PharmacyAlternativesEntryScreenState();
}

class _PharmacyAlternativesEntryScreenState
    extends State<PharmacyAlternativesEntryScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            BlocBuilder<
              PharmacyAlternativesMedicinesCubit,
              PharmacyAlternativesMedicinesState
            >(
              builder: (context, state) {
                return switch (state) {
                  PharmacyAlternativesMedicinesLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  PharmacyAlternativesMedicinesLoadFailure(:final message) =>
                    ProfileLoadError(
                      message: message,
                      onRetry: () => context
                          .read<PharmacyAlternativesMedicinesCubit>()
                          .load(),
                    ),
                  PharmacyAlternativesMedicinesLoaded() => _buildLoaded(
                    context,
                    state,
                  ),
                };
              },
            ),
      ),
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    PharmacyAlternativesMedicinesLoaded state,
  ) {
    final filtered = state.filteredMedicines;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 0),
          child: Column(
            children: [
              StatCardRow(
                cards: [
                  StatCard(
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    value: '${state.needingAlternativeIds.length}',
                    label: 'أدوية تحتاج بديلاً',
                  ),
                  StatCard(
                    icon: Icons.check_circle_outline,
                    color: AppColors.success,
                    value: '${state.alreadyHandledIds.length}',
                    label: 'بدائل محددة',
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              AppTextField(
                controller: _searchController,
                hintText: 'ابحث عن دواء أو مادة فعالة...',
                prefixIcon: Icon(Icons.search, color: AppColors.grey),
                onChanged: (value) => context
                    .read<PharmacyAlternativesMedicinesCubit>()
                    .queryChanged(value),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      state.medicines.isEmpty
                          ? 'لا توجد أدوية في المخزون بعد'
                          : 'لا توجد نتائج مطابقة للبحث',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.cardDescription,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.all(16.r),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final medicine = filtered[index];
                    return _MedicineTile(
                      medicine: medicine,
                      isAlreadyHandled: state.isAlreadyHandled(medicine),
                      onTap: () async {
                        await Navigator.of(context).pushNamed(
                          Routes.pharmacyAlternativesScreen,
                          arguments: medicine,
                        );
                        if (context.mounted) {
                          context
                              .read<PharmacyAlternativesMedicinesCubit>()
                              .load();
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _MedicineTile extends StatelessWidget {
  final Medicine medicine;
  final bool isAlreadyHandled;
  final VoidCallback onTap;

  const _MedicineTile({
    required this.medicine,
    required this.isAlreadyHandled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: AppCard(
        padding: EdgeInsets.all(14.r),
        child: Row(
          children: [
            Icon(Icons.chevron_right, color: AppColors.grey, size: 18.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.displayName,
                    textAlign: TextAlign.right,
                    textDirection: textDirectionFor(medicine.displayName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (medicine.activeIngredient != null &&
                      medicine.activeIngredient!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      medicine.activeIngredient!,
                      textAlign: TextAlign.right,
                      textDirection: textDirectionFor(
                        medicine.activeIngredient!,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.sp, color: AppColors.grey),
                    ),
                  ],
                  if (isAlreadyHandled) ...[
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 12.sp,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'بديل محدد',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              children: [
                MedicineStatusBadge(status: medicine.status),
                SizedBox(height: 4.h),
                Text(
                  '${medicine.quantity} متبقي',
                  style: TextStyle(fontSize: 10.5.sp, color: AppColors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
