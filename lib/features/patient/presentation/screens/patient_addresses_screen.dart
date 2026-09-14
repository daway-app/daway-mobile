import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/models/picked_location.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../widgets/edit_chip.dart';
import '../widgets/patient_sub_screen_header.dart';

class _SavedAddress {
  final String label;
  final PickedLocation location;

  const _SavedAddress({required this.label, required this.location});
}

/// Delivery-address book. There is no backend for named addresses yet, so
/// picked locations only live in this screen's local state (reusing the
/// existing map picker for the actual pick/edit step) rather than being
/// persisted — the first two additions default to "المنزل"/"العمل" to match
/// the design, further ones are just numbered.
class PatientAddressesScreen extends StatefulWidget {
  const PatientAddressesScreen({super.key});

  @override
  State<PatientAddressesScreen> createState() => _PatientAddressesScreenState();
}

class _PatientAddressesScreenState extends State<PatientAddressesScreen> {
  final List<_SavedAddress> _addresses = [];

  String _labelFor(int index) {
    return switch (index) {
      0 => 'المنزل',
      1 => 'العمل',
      _ => 'عنوان ${index + 1}',
    };
  }

  Future<void> _addAddress() async {
    final result = await Navigator.of(context).pushNamed<PickedLocation>(
      Routes.locationPickerScreen,
    );
    if (result == null || !mounted) return;
    setState(() {
      _addresses.add(_SavedAddress(label: _labelFor(_addresses.length), location: result));
    });
  }

  Future<void> _editAddress(_SavedAddress existing) async {
    final result = await Navigator.of(context).pushNamed<PickedLocation>(
      Routes.locationPickerScreen,
      arguments: {
        'latitude': existing.location.latitude,
        'longitude': existing.location.longitude,
        'address': existing.location.address,
      },
    );
    if (result == null || !mounted) return;
    setState(() {
      final index = _addresses.indexOf(existing);
      _addresses[index] = _SavedAddress(label: existing.label, location: result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
              for (final address in _addresses) ...[
                _AddressCard(address: address, onEditTap: () => _editAddress(address)),
                SizedBox(height: 24.h),
              ],
              _AddAddressButton(onTap: _addAddress),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final _SavedAddress address;
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
                SvgPicture.asset(
                  'assets/icons/home_fill_icon.svg',
                  width: 18.w,
                  height: 18.w,
                  colorFilter: const ColorFilter.mode(AppColors.mainTeal, BlendMode.srcIn),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    address.location.address,
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
