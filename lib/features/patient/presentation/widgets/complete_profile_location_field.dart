import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../domain/entities/picked_location.dart';
import '../cubit/complete_profile_cubit.dart';
import '../cubit/complete_profile_state.dart';

/// Tap-to-open field: opening the map picker is a navigation/UI concern, so
/// it lives here rather than in the cubit; only the picked result is handed
/// back to [CompleteProfileCubit]. Goes through the named route (rather than
/// constructing [LocationPickerScreen] inline) so there's a single place
/// that wires up its Cubit.
class CompleteProfileLocationField extends StatelessWidget {
  const CompleteProfileLocationField({super.key});

  Future<void> _openPicker(BuildContext context, CompleteProfileFormData formData) async {
    final result = await Navigator.of(context).pushNamed<PickedLocation>(
      Routes.locationPickerScreen,
      arguments: {
        if (formData.latitude != null) 'latitude': formData.latitude,
        if (formData.longitude != null) 'longitude': formData.longitude,
        if (formData.address != null) 'address': formData.address,
      },
    );
    if (result == null || !context.mounted) return;
    context.read<CompleteProfileCubit>().locationSelected(result);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompleteProfileCubit, CompleteProfileState>(
      buildWhen: (previous, current) =>
          previous.formData.address != current.formData.address ||
          previous.formData.hasLocation != current.formData.hasLocation,
      builder: (context, state) {
        final formData = state.formData;
        return InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => _openPicker(context, formData),
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
                    formData.hasLocation
                        ? (formData.address?.isNotEmpty == true
                            ? formData.address!
                            : '${formData.latitude!.toStringAsFixed(5)}, ${formData.longitude!.toStringAsFixed(5)}')
                        : 'اختر موقعك على الخريطة',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: formData.hasLocation ? AppColors.textDark : AppColors.grey,
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
      },
    );
  }
}
