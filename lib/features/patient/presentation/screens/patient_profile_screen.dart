import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../cubit/patient_profile_cubit.dart';
import '../cubit/patient_profile_state.dart';
import '../widgets/edit_chip.dart';
import '../widgets/patient_profile_avatar.dart';
import '../widgets/patient_sub_screen_header.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  late final TextEditingController _nameController;
  String _controllerBoundTo = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate(BuildContext context, String? current) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(current ?? '') ?? DateTime(now.year - 20),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );
    if (picked == null || !context.mounted) return;
    final year = picked.year.toString().padLeft(4, '0');
    final month = picked.month.toString().padLeft(2, '0');
    final day = picked.day.toString().padLeft(2, '0');
    context.read<PatientProfileCubit>().birthDateChanged('$year-$month-$day');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<PatientProfileCubit, PatientProfileState>(
          listener: (context, state) {
            if (state is PatientProfileLoaded && state.saveError != null) {
              AppSnackbar.show(context, state.saveError!);
            }
            if (state is PatientProfileLoaded && !state.isEditing) {
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
    final cubit = context.read<PatientProfileCubit>();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PatientSubScreenHeader(
            title: 'معلومات الحساب',
            description: 'إدارة معلوماتك الشخصية وتفاصيل حسابك',
          ),
          SizedBox(height: 32.h),
          Center(
            child: PatientProfileAvatar(
              name: state.name,
              avatarLocalPath: state.avatarLocalPath,
              avatarUrl: state.avatarUrl,
              avatarVersion: state.avatarVersion,
              isUploading: state.isUploadingAvatar,
              errorMessage: state.avatarError,
              onImagePicked: (file) => cubit.avatarSelected(file),
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Text(
              state.name,
              style: AppTextStyles.profileFieldLabel,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24.h),
          Text('الاسم', textAlign: TextAlign.right, style: AppTextStyles.profileFieldLabel),
          SizedBox(height: 8.h),
          _ProfileFieldRow(
            onEditTap: () => cubit.toggleEdit(),
            child: state.isEditing
                ? TextField(
                    controller: _nameController,
                    textAlign: TextAlign.right,
                    onChanged: (value) => cubit.nameChanged(value),
                    style: AppTextStyles.profileFieldValue,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Text(
                    state.name,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.profileFieldValue,
                  ),
          ),
          SizedBox(height: 24.h),
          Text('رقم الهاتف', textAlign: TextAlign.right, style: AppTextStyles.profileFieldLabel),
          SizedBox(height: 8.h),
          _ProfileFieldRow(
            onEditTap: () => cubit.toggleEdit(),
            child: Text(
              state.profile.phone,
              textAlign: TextAlign.right,
              style: AppTextStyles.profileFieldValue,
            ),
          ),
          SizedBox(height: 24.h),
          Text('تاريخ الميلاد', textAlign: TextAlign.right, style: AppTextStyles.profileFieldLabel),
          SizedBox(height: 8.h),
          _ProfileFieldRow(
            onEditTap: () => cubit.toggleEdit(),
            child: GestureDetector(
              onTap: state.isEditing ? () => _pickBirthDate(context, state.birthDate) : null,
              child: Text(
                state.birthDate ?? 'اختر تاريخ ميلادك',
                textAlign: TextAlign.right,
                style: AppTextStyles.profileFieldValue,
              ),
            ),
          ),
          SizedBox(height: 48.h),
          AppCustomButton(
            text: 'حفظ التعديلات',
            isLoading: state.isSaving,
            backgroundColor: state.canSave ? AppColors.mainTeal : AppColors.borderGrey,
            onPressed: state.canSave ? () => cubit.save() : () {},
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _ProfileFieldRow extends StatelessWidget {
  final Widget child;
  final VoidCallback onEditTap;

  const _ProfileFieldRow({required this.child, required this.onEditTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(child: child),
          SizedBox(width: 8.w),
          EditChip(onTap: onEditTap),
        ],
      ),
    );
  }
}
