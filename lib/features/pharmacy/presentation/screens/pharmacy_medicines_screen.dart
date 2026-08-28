import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_filter_chip.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../../domain/entities/medicine.dart';
import '../cubit/pharmacy_medicines_cubit.dart';
import '../cubit/pharmacy_medicines_state.dart';
import '../widgets/delete_medicine_confirmation_dialog.dart';
import '../widgets/medicine_card.dart';
import '../widgets/pharmacy_side_menu.dart';

class PharmacyMedicinesScreen extends StatefulWidget {
  const PharmacyMedicinesScreen({super.key});

  @override
  State<PharmacyMedicinesScreen> createState() => _PharmacyMedicinesScreenState();
}

class _PharmacyMedicinesScreenState extends State<PharmacyMedicinesScreen> {
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

  Future<void> _openAddMedicine(BuildContext context) async {
    final added = await Navigator.of(context).pushNamed(Routes.addPharmacyMedicineScreen);
    if (added == true && context.mounted) {
      context.read<PharmacyMedicinesCubit>().load();
    }
  }

  Future<void> _openEditMedicine(BuildContext context, Medicine medicine) async {
    final edited = await Navigator.of(context)
        .pushNamed(Routes.editPharmacyMedicineScreen, arguments: medicine);
    if (edited == true && context.mounted) {
      context.read<PharmacyMedicinesCubit>().load();
    }
  }

  void _confirmDelete(BuildContext context, Medicine medicine) {
    DeleteMedicineConfirmationDialog.show(
      context,
      medicineName: medicine.name,
      onConfirm: () async {
        final cubit = context.read<PharmacyMedicinesCubit>();
        final error = await cubit.deleteMedicine(medicine.id);
        if (error != null && context.mounted) {
          AppSnackbar.show(context, error);
        }
      },
    );
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
          'الأدوية',
          style: AppTextStyles.screenTitle.copyWith(color: AppColors.mainTeal, fontSize: 20.sp),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: AppColors.mainTeal),
            onPressed: () => AppSnackbar.show(context, 'قريباً'),
          ),
        ],
      ),
      drawer: const PharmacySideMenu(),
      body: SafeArea(
        child: BlocBuilder<PharmacyMedicinesCubit, PharmacyMedicinesState>(
          builder: (context, state) {
            return switch (state) {
              PharmacyMedicinesLoading() => const Center(child: CircularProgressIndicator()),
              PharmacyMedicinesLoadFailure(:final message) => ProfileLoadError(
                  message: message,
                  onRetry: () => context.read<PharmacyMedicinesCubit>().load(),
                ),
              PharmacyMedicinesLoaded() => _buildLoaded(context, state),
            };
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: BlocBuilder<PharmacyMedicinesCubit, PharmacyMedicinesState>(
        builder: (context, state) {
          if (state is! PharmacyMedicinesLoaded) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _openAddMedicine(context),
            backgroundColor: AppColors.mainTeal,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('إضافة دواء'),
          );
        },
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, PharmacyMedicinesLoaded state) {
    final filtered = state.filteredMedicines;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _searchController,
                hintText: 'ابحث باسم الدواء أو المادة الفعالة',
                prefixIcon: Icon(Icons.search, color: AppColors.grey),
                onChanged: (value) => context.read<PharmacyMedicinesCubit>().queryChanged(value),
              ),
              SizedBox(height: 12.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    AppFilterChip(
                      label: 'الكل',
                      selected: state.filter == MedicineStatusFilter.all,
                      onTap: () => context
                          .read<PharmacyMedicinesCubit>()
                          .filterChanged(MedicineStatusFilter.all),
                    ),
                    SizedBox(width: 8.w),
                    AppFilterChip(
                      label: 'متوفر',
                      color: AppColors.success,
                      selected: state.filter == MedicineStatusFilter.available,
                      onTap: () => context
                          .read<PharmacyMedicinesCubit>()
                          .filterChanged(MedicineStatusFilter.available),
                    ),
                    SizedBox(width: 8.w),
                    AppFilterChip(
                      label: 'منخفض',
                      color: AppColors.warning,
                      selected: state.filter == MedicineStatusFilter.low,
                      onTap: () => context
                          .read<PharmacyMedicinesCubit>()
                          .filterChanged(MedicineStatusFilter.low),
                    ),
                    SizedBox(width: 8.w),
                    AppFilterChip(
                      label: 'نافد',
                      color: AppColors.error,
                      selected: state.filter == MedicineStatusFilter.outOfStock,
                      onTap: () => context
                          .read<PharmacyMedicinesCubit>()
                          .filterChanged(MedicineStatusFilter.outOfStock),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text('لا توجد أدوية مطابقة', style: AppTextStyles.cardDescription),
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 88.h),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final medicine = filtered[index];
                    return MedicineCard(
                      medicine: medicine,
                      onEdit: () => _openEditMedicine(context, medicine),
                      onDelete: () => _confirmDelete(context, medicine),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
