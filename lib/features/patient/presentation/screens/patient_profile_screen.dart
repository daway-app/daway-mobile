import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/birth_date_field.dart';
import '../../../../core/widgets/incomplete_profile_banner.dart';
import '../../../../core/widgets/profile_avatar_picker.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../../../../core/widgets/profile_location_field.dart';
import '../cubit/patient_profile_cubit.dart';
import '../cubit/patient_profile_state.dart';
import '../widgets/patient_side_menu.dart';

/// The "حسابي" tab: view/edit a patient's own profile. Loads it from the
/// server on open, starts in read-only mode, and switches to editable
/// fields only after "تعديل" is tapped.
class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  String _controllerBoundTo = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
        title: Text('حسابي', style: AppTextStyles.screenTitle),
      ),
      drawer: const PatientSideMenu(),
      body: SafeArea(
        child: BlocConsumer<PatientProfileCubit, PatientProfileState>(
          listener: (context, state) {
            if (state is PatientProfileLoaded && state.saveError != null) {
              AppSnackbar.show(context, state.saveError!);
            }
            if (state is PatientProfileLoaded && !state.isEditing) {
              // Keep the field in sync whenever we're not actively typing
              // (initial load, entering edit mode, cancel, or a fresh save).
              if (_controllerBoundTo != state.name) {
                _nameController.text = state.name;
                _controllerBoundTo = state.name;
              }
            }
          },
          builder: (context, state) {
            return switch (state) {
              PatientProfileLoading() => const Center(child: CircularProgressIndicator()),
              PatientProfileLoadFailure(:final message) => ProfileLoadError(
                  message: message,
                  onRetry: () => context.read<PatientProfileCubit>().load(),
                ),
              PatientProfileLoaded() => _buildLoaded(context, state),
            };
          },
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, PatientProfileLoaded state) {
    if (_phoneController.text.isEmpty) {
      _phoneController.text = state.profile.phone;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.isIncomplete) ...[
            const IncompleteProfileBanner(),
            SizedBox(height: 16.h),
          ],
          Center(
            child: ProfileAvatarPicker(
              avatarLocalPath: state.avatarLocalPath,
              avatarUrl: state.avatarUrl,
              isUploading: state.isUploadingAvatar,
              errorMessage: state.avatarError,
              onImagePicked: (file) => context.read<PatientProfileCubit>().avatarSelected(file),
            ),
          ),
          SizedBox(height: 24.h),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('الاسم الكامل', style: AppTextStyles.inputLabel),
                SizedBox(height: 8.h),
                AppTextField(
                  controller: _nameController,
                  readOnly: !state.isEditing,
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.grey, size: 20.sp),
                  onChanged: (value) => context.read<PatientProfileCubit>().nameChanged(value),
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
                BirthDateField(
                  birthDate: state.birthDate,
                  enabled: state.isEditing,
                  onChanged: (value) =>
                      context.read<PatientProfileCubit>().birthDateChanged(value),
                ),
                SizedBox(height: 16.h),
                Text('الموقع', style: AppTextStyles.inputLabel),
                SizedBox(height: 8.h),
                IgnorePointer(
                  ignoring: !state.isEditing,
                  child: ProfileLocationField(
                    hasLocation: state.hasLocation,
                    latitude: state.latitude,
                    longitude: state.longitude,
                    address: state.address,
                    onLocationPicked: (location) =>
                        context.read<PatientProfileCubit>().locationSelected(location),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: AppCustomButton(
                  text: 'حفظ',
                  isLoading: state.isSaving,
                  backgroundColor:
                      state.isEditing && state.canSave ? AppColors.mainTeal : AppColors.borderGrey,
                  onPressed: state.isEditing && state.canSave
                      ? () => context.read<PatientProfileCubit>().save()
                      : () {},
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.read<PatientProfileCubit>().toggleEdit(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 55.h),
                    side: const BorderSide(color: AppColors.mainTeal),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(
                    state.isEditing ? 'إلغاء' : 'تعديل',
                    style: TextStyle(
                      color: AppColors.mainTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
