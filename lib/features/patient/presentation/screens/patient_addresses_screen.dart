import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/models/picked_location.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../../domain/entities/patient_address.dart';
import '../cubit/patient_addresses_cubit.dart';
import '../cubit/patient_addresses_state.dart';
import '../widgets/address_sheets.dart';
import '../widgets/edit_chip.dart';
import '../widgets/patient_sub_screen_header.dart';

/// "عناويني" — backed by the real `/patient/addresses` endpoints. The screen
/// has no name/phone fields of its own, so [PatientAddressesCubit] borrows
/// the patient's profile for those on a new address, and keeps an edited
/// one's existing name/phone unchanged.
class PatientAddressesScreen extends StatelessWidget {
  const PatientAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PatientAddressesCubit>(),
      child: const _AddressesView(),
    );
  }
}

class _AddressesView extends StatefulWidget {
  const _AddressesView();

  @override
  State<_AddressesView> createState() => _AddressesViewState();
}

class _AddressesViewState extends State<_AddressesView> {
  Future<void> _addAddress() async {
    final location = await Navigator.of(context).pushNamed<PickedLocation>(
      Routes.locationPickerScreen,
    );
    if (location == null || !mounted) return;
    final label = await showAddressLabelSheet(context);
    if (label == null || !mounted) return;
    final error =
        await context.read<PatientAddressesCubit>().addAddress(location, label: label);
    if (error != null && mounted) AppSnackbar.show(context, error);
  }

  Future<void> _editAddress(PatientAddress existing) async {
    final result = await showAddressEditSheet(context, existing);
    if (result == null || !mounted) return;
    final cubit = context.read<PatientAddressesCubit>();

    String? error;
    switch (result.action) {
      case AddressEditAction.save:
        if (result.label == existing.label) return;
        error = await cubit.updateAddress(existing, null, label: result.label);
      case AddressEditAction.changeLocation:
        final location = await Navigator.of(context).pushNamed<PickedLocation>(
          Routes.locationPickerScreen,
          arguments: {
            'latitude': existing.latitude,
            'longitude': existing.longitude,
            'address': existing.address,
          },
        );
        if (location == null || !mounted) return;
        error = await cubit.updateAddress(existing, location, label: result.label);
      case AddressEditAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('حذف العنوان'),
            content: Text('هل تريد حذف عنوان "${existing.label}"؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text('حذف', style: TextStyle(color: AppColors.logoutRed)),
              ),
            ],
          ),
        );
        if (confirmed != true || !mounted) return;
        error = await cubit.deleteAddress(existing);
    }
    if (error != null && mounted) AppSnackbar.show(context, error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PatientSubScreenHeader(
                title: 'عناويني',
                description: 'أدر عناوين التوصيل الخاصة بك',
              ),
              SizedBox(height: 32.h),
              BlocBuilder<PatientAddressesCubit, PatientAddressesState>(
                builder: (context, state) {
                  return switch (state) {
                    PatientAddressesLoading() =>
                      const Center(child: CircularProgressIndicator()),
                    PatientAddressesLoadFailure(:final message) => ProfileLoadError(
                        message: message,
                        onRetry: () => context.read<PatientAddressesCubit>().load(),
                      ),
                    PatientAddressesLoaded(:final addresses) when addresses.isEmpty =>
                      EmptyStateView(
                        imageAsset: 'assets/images/empty_addresses.png',
                        title: 'لا يوجد عناوين محفوظة',
                        actionLabel: 'أضف عنوان',
                        onActionTap: _addAddress,
                      ),
                    PatientAddressesLoaded(:final addresses) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final address in addresses) ...[
                            _AddressCard(
                              address: address,
                              onEditTap: () => _editAddress(address),
                            ),
                            SizedBox(height: 24.h),
                          ],
                          _AddAddressButton(onTap: _addAddress),
                          SizedBox(height: 24.h),
                        ],
                      ),
                  };
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final PatientAddress address;
  final VoidCallback onEditTap;

  const _AddressCard({required this.address, required this.onEditTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  address.label,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.addressCardTitle,
                ),
              ),
              SizedBox(width: 8.w),
              EditChip(onTap: onEditTap),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.permissionIconBg,
              border: Border.all(color: AppColors.iconBlueBorder, width: 1.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    address.address,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.profileFieldValue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddAddressButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddAddressButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          'اضافة عنوان',
          textAlign: TextAlign.right,
          style: AppTextStyles.addressCardTitle,
        ),
      ),
    );
  }
}
