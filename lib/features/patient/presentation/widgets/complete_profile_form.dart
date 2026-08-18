import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/birth_date_field.dart';
import '../../../../core/widgets/profile_avatar_picker.dart';
import '../../../../core/widgets/profile_location_field.dart';
import '../cubit/complete_profile_cubit.dart';
import '../cubit/complete_profile_state.dart';

class CompleteProfileForm extends StatefulWidget {
  const CompleteProfileForm({super.key});

  @override
  State<CompleteProfileForm> createState() => _CompleteProfileFormState();
}

class _CompleteProfileFormState extends State<CompleteProfileForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController(
      text: context.read<CompleteProfileCubit>().state.formData.phone,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Center(
          child: BlocBuilder<CompleteProfileCubit, CompleteProfileState>(
            buildWhen: (previous, current) =>
                previous.formData.avatarLocalPath != current.formData.avatarLocalPath ||
                previous.formData.isUploadingAvatar != current.formData.isUploadingAvatar ||
                previous.formData.avatarError != current.formData.avatarError,
            builder: (context, state) => ProfileAvatarPicker(
              avatarLocalPath: state.formData.avatarLocalPath,
              isUploading: state.formData.isUploadingAvatar,
              errorMessage: state.formData.avatarError,
              onImagePicked: (file) =>
                  context.read<CompleteProfileCubit>().avatarSelected(file),
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Text('الاسم الكامل', style: AppTextStyles.inputLabel),
        SizedBox(height: 8.h),
        AppTextField(
          controller: _nameController,
          hintText: 'أدخل اسمك الكامل',
          prefixIcon: Icon(Icons.person_outline, color: AppColors.grey, size: 20.sp),
          onChanged: (value) => context.read<CompleteProfileCubit>().nameChanged(value),
        ),
        SizedBox(height: 16.h),
        Text('رقم الهاتف', style: AppTextStyles.inputLabel),
        SizedBox(height: 8.h),
        AppTextField(
          controller: _phoneController,
          textAlign: TextAlign.left,
          prefixIcon: Icon(Icons.lock_outline, color: AppColors.grey, size: 18.sp),
          readOnly: true,
        ),
        SizedBox(height: 16.h),
        Text('تاريخ الميلاد', style: AppTextStyles.inputLabel),
        SizedBox(height: 8.h),
        BlocBuilder<CompleteProfileCubit, CompleteProfileState>(
          buildWhen: (previous, current) =>
              previous.formData.birthDate != current.formData.birthDate,
          builder: (context, state) => BirthDateField(
            birthDate: state.formData.birthDate,
            enabled: true,
            onChanged: (value) =>
                context.read<CompleteProfileCubit>().birthDateChanged(value),
          ),
        ),
        SizedBox(height: 16.h),
        Text('الموقع', style: AppTextStyles.inputLabel),
        SizedBox(height: 8.h),
        BlocBuilder<CompleteProfileCubit, CompleteProfileState>(
          buildWhen: (previous, current) =>
              previous.formData.address != current.formData.address ||
              previous.formData.hasLocation != current.formData.hasLocation,
          builder: (context, state) => ProfileLocationField(
            hasLocation: state.formData.hasLocation,
            latitude: state.formData.latitude,
            longitude: state.formData.longitude,
            address: state.formData.address,
            onLocationPicked: (location) =>
                context.read<CompleteProfileCubit>().locationSelected(location),
          ),
        ),
        SizedBox(height: 24.h),
        BlocBuilder<CompleteProfileCubit, CompleteProfileState>(
          builder: (context, state) {
            final canSubmit = state.formData.canSubmit && state is! CompleteProfileLoading;
            return AppCustomButton(
              text: 'حفظ ومتابعة',
              isLoading: state is CompleteProfileLoading,
              onPressed: canSubmit
                  ? () => context.read<CompleteProfileCubit>().submit()
                  : () {},
              backgroundColor: canSubmit ? AppColors.mainTeal : AppColors.borderGrey,
            );
          },
        ),
      ],
    );
  }
}
