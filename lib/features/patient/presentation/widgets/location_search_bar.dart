import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../cubit/location_picker_cubit.dart';
import '../cubit/location_picker_state.dart';

/// Free-text address search bar floated over the top of the map. Reuses
/// [AppTextField] (with a Material wrapper for the floating shadow) rather
/// than hand-rolling a second input style.
class LocationSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const LocationSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12.r),
      color: Colors.white,
      child: AppTextField(
        controller: controller,
        hintText: 'ابحث عن عنوان...',
        textInputAction: TextInputAction.search,
        onSubmitted: (value) => context.read<LocationPickerCubit>().search(value),
        prefixIcon: BlocBuilder<LocationPickerCubit, LocationPickerState>(
          buildWhen: (previous, current) => previous.isSearching != current.isSearching,
          builder: (context, state) {
            if (state.isSearching) {
              return Padding(
                padding: EdgeInsets.all(14.r),
                child: const CircularProgressIndicator(strokeWidth: 2),
              );
            }
            return IconButton(
              icon: Icon(Icons.search, color: AppColors.grey),
              onPressed: () => context.read<LocationPickerCubit>().search(controller.text),
            );
          },
        ),
      ),
    );
  }
}
