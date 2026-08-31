import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_filter_chip.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../../domain/entities/medicine.dart';
import '../cubit/pharmacy_inventory_cubit.dart';
import '../cubit/pharmacy_inventory_state.dart';
import '../helpers/medicine_text_display.dart';
import '../helpers/notifications_navigation.dart';
import '../widgets/medicine_status_badge.dart';
import '../widgets/pharmacy_side_menu.dart';

class PharmacyInventoryScreen extends StatefulWidget {
  const PharmacyInventoryScreen({super.key});

  @override
  State<PharmacyInventoryScreen> createState() => _PharmacyInventoryScreenState();
}

class _PharmacyInventoryScreenState extends State<PharmacyInventoryScreen> {
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

  void _syncController(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
    controller.selection = TextSelection.collapsed(offset: value.length);
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
          'إدارة المخزون',
          style: AppTextStyles.screenTitle.copyWith(color: AppColors.mainTeal, fontSize: 20.sp),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: AppColors.mainTeal),
            onPressed: () => openNotifications(context),
          ),
        ],
      ),
      drawer: const PharmacySideMenu(),
      body: SafeArea(
        child: BlocConsumer<PharmacyInventoryCubit, PharmacyInventoryState>(
          listenWhen: (previous, current) {
            final previousError = previous is PharmacyInventoryLoaded ? previous.saveError : null;
            final currentError = current is PharmacyInventoryLoaded ? current.saveError : null;
            return currentError != null && currentError != previousError;
          },
          listener: (context, state) {
            AppSnackbar.show(context, (state as PharmacyInventoryLoaded).saveError!);
          },
          builder: (context, state) {
            if (state is PharmacyInventoryLoaded) {
              _syncController(_searchController, state.query);
            }
            return switch (state) {
              PharmacyInventoryLoading() => const Center(child: CircularProgressIndicator()),
              PharmacyInventoryLoadFailure(:final message) => ProfileLoadError(
                  message: message,
                  onRetry: () => context.read<PharmacyInventoryCubit>().load(),
                ),
              PharmacyInventoryLoaded() => _buildLoaded(context, state),
            };
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: BlocBuilder<PharmacyInventoryCubit, PharmacyInventoryState>(
        builder: (context, state) {
          if (state is! PharmacyInventoryLoaded) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () {
              if (state.hasPendingChanges && !state.isSaving) {
                context.read<PharmacyInventoryCubit>().save();
              }
            },
            backgroundColor: AppColors.mainTeal,
            foregroundColor: Colors.white,
            icon: state.isSaving
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('حفظ التحديثات'),
          );
        },
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, PharmacyInventoryLoaded state) {
    final filtered = state.filteredMedicines;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'أضف أو عدّل كميات الأدوية المتوفرة في الصيدلية',
                style: AppTextStyles.cardDescription,
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 16.h),
              BlocSelector<PharmacyInventoryCubit, PharmacyInventoryState,
                  ({int available, int low, int outOfStock})?>(
                selector: (state) => state is PharmacyInventoryLoaded ? state.statusTally : null,
                builder: (context, tally) {
                  if (tally == null) return const SizedBox.shrink();
                  return _InventoryStatsCard(tally: tally);
                },
              ),
              SizedBox(height: 16.h),
              AppTextField(
                controller: _searchController,
                hintText: 'ابحث عن دواء...',
                prefixIcon: Icon(Icons.search, color: AppColors.grey),
                onChanged: (value) => context.read<PharmacyInventoryCubit>().queryChanged(value),
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
                          .read<PharmacyInventoryCubit>()
                          .filterChanged(MedicineStatusFilter.all),
                    ),
                    SizedBox(width: 8.w),
                    AppFilterChip(
                      label: 'متوفر',
                      color: AppColors.success,
                      selected: state.filter == MedicineStatusFilter.available,
                      onTap: () => context
                          .read<PharmacyInventoryCubit>()
                          .filterChanged(MedicineStatusFilter.available),
                    ),
                    SizedBox(width: 8.w),
                    AppFilterChip(
                      label: 'منخفض',
                      color: AppColors.warning,
                      selected: state.filter == MedicineStatusFilter.low,
                      onTap: () => context
                          .read<PharmacyInventoryCubit>()
                          .filterChanged(MedicineStatusFilter.low),
                    ),
                    SizedBox(width: 8.w),
                    AppFilterChip(
                      label: 'نافد',
                      color: AppColors.error,
                      selected: state.filter == MedicineStatusFilter.outOfStock,
                      onTap: () => context
                          .read<PharmacyInventoryCubit>()
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
                    return _InventoryItemTile(
                      medicine: medicine,
                      quantity: state.quantityFor(medicine),
                      status: state.statusFor(medicine),
                      onIncrement: () => context.read<PharmacyInventoryCubit>().increment(medicine),
                      onDecrement: () => context.read<PharmacyInventoryCubit>().decrement(medicine),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _InventoryStatsCard extends StatelessWidget {
  final ({int available, int low, int outOfStock}) tally;

  const _InventoryStatsCard({required this.tally});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatTile(label: 'متوفر', value: tally.available, color: AppColors.success),
          ),
          const _StatDivider(),
          Expanded(
            child: _StatTile(label: 'منخفض', value: tally.low, color: AppColors.warning),
          ),
          const _StatDivider(),
          Expanded(
            child: _StatTile(label: 'نافد', value: tally.outOfStock, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40.h, color: AppColors.borderGrey);
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: color),
        ),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: color)),
        Text('دواء', style: TextStyle(fontSize: 11.sp, color: AppColors.grey)),
      ],
    );
  }
}

class _InventoryItemTile extends StatelessWidget {
  final Medicine medicine;
  final int quantity;
  final MedicineStatus status;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _InventoryItemTile({
    required this.medicine,
    required this.quantity,
    required this.status,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final shouty = isShoutyLatinName(medicine.displayName);

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: (medicine.imageUrl != null && medicine.imageUrl!.isNotEmpty)
                ? Image.network(
                    medicine.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.medication_outlined, color: AppColors.grey, size: 24.sp),
                  )
                : Icon(Icons.medication_outlined, color: AppColors.grey, size: 24.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.displayName,
                  style: TextStyle(
                    fontSize: shouty ? 13.sp : 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: textDirectionFor(medicine.displayName),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (medicine.activeIngredient != null && medicine.activeIngredient!.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    medicine.activeIngredient!,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.grey),
                    textAlign: TextAlign.right,
                    textDirection: textDirectionFor(medicine.activeIngredient!),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            children: [
              MedicineStatusBadge(status: status),
              SizedBox(height: 10.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StepperButton(icon: Icons.remove, onTap: onDecrement),
                  SizedBox(
                    width: 32.w,
                    child: Text(
                      '$quantity',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                  ),
                  _StepperButton(icon: Icons.add, onTap: onIncrement),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          color: AppColors.mainTeal.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16.sp, color: AppColors.mainTeal),
      ),
    );
  }
}
