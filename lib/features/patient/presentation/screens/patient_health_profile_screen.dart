import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../../domain/entities/patient_health_profile.dart';
import '../cubit/health_profile_cubit.dart';
import '../cubit/health_profile_state.dart';
import '../widgets/patient_sub_screen_header.dart';

/// "الملف الصحي" — blood type, allergies, chronic diseases and notes, backed
/// by `/patient/health-profile`.
class PatientHealthProfileScreen extends StatelessWidget {
  const PatientHealthProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HealthProfileCubit>(),
      child: const _HealthProfileView(),
    );
  }
}

class _HealthProfileView extends StatefulWidget {
  const _HealthProfileView();

  @override
  State<_HealthProfileView> createState() => _HealthProfileViewState();
}

class _HealthProfileViewState extends State<_HealthProfileView> {
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    final error = await context.read<HealthProfileCubit>().save(_notesController.text);
    if (!context.mounted) return;
    AppSnackbar.show(context, error ?? 'تم حفظ الملف الصحي');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<HealthProfileCubit, HealthProfileState>(
          // Fill the notes box once, when the profile first arrives (or is
          // reloaded); later emits (chips, saving) must not overwrite typing.
          listenWhen: (previous, current) =>
              previous is! HealthProfileLoaded && current is HealthProfileLoaded,
          listener: (context, state) {
            if (state is HealthProfileLoaded) _notesController.text = state.notes;
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PatientSubScreenHeader(
                    title: 'الملف الصحي',
                    description: 'معلوماتك الطبية تساعد الصيدلي على اقتراح الدواء المناسب لك.',
                  ),
                  SizedBox(height: 24.h),
                  switch (state) {
                    HealthProfileLoading() => Padding(
                        padding: EdgeInsets.only(top: 48.h),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    HealthProfileLoadFailure(:final message) => ProfileLoadError(
                        message: message,
                        onRetry: () => context.read<HealthProfileCubit>().load(),
                      ),
                    HealthProfileLoaded() => _Form(
                        state: state,
                        notesController: _notesController,
                        onSave: () => _save(context),
                      ),
                  },
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  final HealthProfileLoaded state;
  final TextEditingController notesController;
  final VoidCallback onSave;

  const _Form({required this.state, required this.notesController, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HealthProfileCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('فصيلة الدم', textAlign: TextAlign.right, style: AppTextStyles.profileFieldLabel),
        SizedBox(height: 8.h),
        Wrap(
          alignment: WrapAlignment.start,
          spacing: 10.w,
          runSpacing: 10.h,
          children: [
            for (final type in bloodTypes)
              _Chip(
                label: type,
                selected: state.bloodType == type,
                onTap: () => cubit.selectBloodType(type),
              ),
          ],
        ),
        SizedBox(height: 24.h),
        _ListSection(
          title: 'الحساسية',
          hint: 'أضف حساسية (مثل: بنسلين)',
          items: state.allergies,
          onAdd: cubit.addAllergy,
          onRemove: cubit.removeAllergy,
        ),
        SizedBox(height: 24.h),
        _ListSection(
          title: 'الأمراض المزمنة',
          hint: 'أضف مرضاً مزمناً (مثل: السكري)',
          items: state.chronicDiseases,
          onAdd: cubit.addChronicDisease,
          onRemove: cubit.removeChronicDisease,
        ),
        SizedBox(height: 24.h),
        Text('ملاحظات', textAlign: TextAlign.right, style: AppTextStyles.profileFieldLabel),
        SizedBox(height: 8.h),
        AppTextField(
          controller: notesController,
          hintText: 'أي معلومات صحية أخرى',
          maxLines: 4,
          fillColor: Colors.white,
        ),
        SizedBox(height: 32.h),
        AppCustomButton(text: 'حفظ', isLoading: state.isSaving, onPressed: onSave),
        SizedBox(height: 24.h),
      ],
    );
  }
}

/// A titled list of removable chips with an input row to add one.
class _ListSection extends StatefulWidget {
  final String title;
  final String hint;
  final List<String> items;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const _ListSection({
    required this.title,
    required this.hint,
    required this.items,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<_ListSection> createState() => _ListSectionState();
}

class _ListSectionState extends State<_ListSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    widget.onAdd(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.title, textAlign: TextAlign.right, style: AppTextStyles.profileFieldLabel),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _controller,
                hintText: widget.hint,
                fillColor: Colors.white,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _add(),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: _add,
              child: Container(
                width: 48.w,
                height: 48.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.permissionIconBg,
                  border: Border.all(color: AppColors.iconBlueBorder),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.add, color: AppColors.mainTeal, size: 24.sp),
              ),
            ),
          ],
        ),
        if (widget.items.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              for (final item in widget.items)
                _Chip(
                  label: item,
                  selected: true,
                  onTap: () => widget.onRemove(item),
                  removable: true,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool removable;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.removable = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.mainTeal : AppColors.permissionIconBg,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : AppColors.onboardingText,
              ),
            ),
            if (removable) ...[
              SizedBox(width: 6.w),
              Icon(Icons.close, size: 14.sp, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}
