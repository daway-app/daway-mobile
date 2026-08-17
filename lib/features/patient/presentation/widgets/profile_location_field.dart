import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../domain/entities/picked_location.dart';

/// Tap-to-open field: opening the map picker is a navigation/UI concern, so
/// it lives here rather than in a cubit; only the picked result is handed
/// back via [onLocationPicked]. Goes through the named route (rather than
/// constructing [LocationPickerScreen] inline) so there's a single place
/// that wires up its Cubit. Pure display + callback so it's reusable across
/// any screen that edits a location (profile completion, profile editing).
class ProfileLocationField extends StatelessWidget {
  final bool hasLocation;
  final double? latitude;
  final double? longitude;
  final String? address;
  final ValueChanged<PickedLocation> onLocationPicked;

  const ProfileLocationField({
    super.key,
    required this.hasLocation,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.onLocationPicked,
  });

  Future<void> _openPicker(BuildContext context) async {
    final result = await Navigator.of(context).pushNamed<PickedLocation>(
      Routes.locationPickerScreen,
      arguments: {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (address != null) 'address': address,
      },
    );
    if (result == null || !context.mounted) return;
    onLocationPicked(result);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () => _openPicker(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined, color: AppColors.grey, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                hasLocation
                    ? (address?.isNotEmpty == true
                        ? address!
                        : '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}')
                    : 'اختر موقعك على الخريطة',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: hasLocation ? AppColors.textDark : AppColors.grey,
                ),
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
