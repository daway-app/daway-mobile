import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/digits_only_formatter.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/medicine_catalog_item.dart';
import '../cubit/add_medicine_cubit.dart';
import '../cubit/add_medicine_state.dart';
import '../widgets/medicine_image_picker.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _nameArController;
  late final TextEditingController _activeIngredientController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  bool _attemptedSave = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameArController = TextEditingController();
    _activeIngredientController = TextEditingController();
    _priceController = TextEditingController();
    _quantityController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _activeIngredientController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          'إضافة دواء',
          style: AppTextStyles.screenTitle.copyWith(color: AppColors.mainTeal, fontSize: 20.sp),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<AddMedicineCubit, AddMedicineState>(
          listener: (context, state) {
            if (state is AddMedicineFailure) {
              AppSnackbar.show(context, state.message);
            }
            if (state is AddMedicineSuccess) {
              Navigator.of(context).pop(true);
            }
          },
          builder: (context, state) {
            final formData = state.formData;
            _syncController(_nameController, formData.nameQuery);
            _syncController(_nameArController, formData.nameAr);
            _syncController(_activeIngredientController, formData.activeIngredient);
            _syncController(_priceController, formData.price);
            _syncController(_quantityController, formData.quantity);

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MedicineImagePicker(
                    imageLocalPath: formData.imageLocalPath,
                    imageUrl: formData.imageUrl,
                    isUploading: formData.isUploadingImage,
                    errorMessage: formData.imageError,
                    onImagePicked: (file) => context.read<AddMedicineCubit>().imageSelected(file),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    formData.isManualEntry ? 'الاسم التجاري (بالإنجليزي) *' : 'الاسم التجاري *',
                    style: AppTextStyles.inputLabel,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    formData.isManualEntry
                        ? 'أدخل اسم الدواء بالإنجليزي'
                        : 'ابحث واختر الدواء من القائمة المقترحة',
                    style: AppTextStyles.helperText,
                  ),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: _nameController,
                    hintText: 'مثال: Panadol',
                    prefixIcon: Icon(Icons.medication_outlined, color: AppColors.grey, size: 20.sp),
                    onChanged: (value) => context.read<AddMedicineCubit>().nameQueryChanged(value),
                  ),
                  if (!formData.isManualEntry) ...[
                    if (formData.isSearching) ...[
                      SizedBox(height: 8.h),
                      const LinearProgressIndicator(),
                    ],
                    if (formData.suggestions.isNotEmpty)
                      _SuggestionsList(
                        suggestions: formData.suggestions,
                        onSelected: (item) =>
                            context.read<AddMedicineCubit>().medicineSelected(item),
                      ),
                    if (formData.searchError != null) ...[
                      SizedBox(height: 6.h),
                      Text(formData.searchError!, style: AppTextStyles.errorText),
                    ],
                  ],
                  if (formData.isManualEntry && formData.nameHasArabicChars) ...[
                    SizedBox(height: 6.h),
                    Text('يجب أن يكون الاسم التجاري بالإنجليزي فقط', style: AppTextStyles.errorText),
                  ],
                  if (_attemptedSave &&
                      !formData.isManualEntry &&
                      formData.selectedMedicine == null) ...[
                    SizedBox(height: 6.h),
                    Text('اختر الدواء من القائمة المقترحة', style: AppTextStyles.errorText),
                  ],
                  if (_attemptedSave &&
                      formData.isManualEntry &&
                      formData.nameQuery.trim().isEmpty) ...[
                    SizedBox(height: 6.h),
                    Text('هذا الحقل مطلوب', style: AppTextStyles.errorText),
                  ],
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () => context.read<AddMedicineCubit>().manualEntryToggled(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.borderGrey),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      ),
                      child: Text(
                        formData.isManualEntry
                            ? 'الرجوع للبحث عن دواء'
                            : 'الدواء غير موجود؟ أضفه يدوياً',
                        style: TextStyle(fontSize: 13.sp, color: AppColors.textDark),
                      ),
                    ),
                  ),
                  if (formData.isManualEntry) ...[
                    SizedBox(height: 16.h),
                    Text('الاسم بالعربي (اختياري)', style: AppTextStyles.inputLabel),
                    SizedBox(height: 8.h),
                    AppTextField(
                      controller: _nameArController,
                      hintText: 'مثال: بانادول',
                      prefixIcon:
                          Icon(Icons.medication_outlined, color: AppColors.grey, size: 20.sp),
                      onChanged: (value) => context.read<AddMedicineCubit>().nameArChanged(value),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  Text('المادة الفعالة', style: AppTextStyles.inputLabel),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: _activeIngredientController,
                    hintText: 'أدخل المادة الفعالة',
                    prefixIcon: Icon(Icons.science_outlined, color: AppColors.grey, size: 20.sp),
                    onChanged: (value) =>
                        context.read<AddMedicineCubit>().activeIngredientChanged(value),
                  ),
                  SizedBox(height: 16.h),
                  Text('السعر *', style: AppTextStyles.inputLabel),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: _priceController,
                    hintText: 'أدخل السعر',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                    prefixIcon: Icon(Icons.sell_outlined, color: AppColors.grey, size: 20.sp),
                    onChanged: (value) => context.read<AddMedicineCubit>().priceChanged(value),
                  ),
                  if (_attemptedSave && (formData.priceValue ?? 0) <= 0) ...[
                    SizedBox(height: 6.h),
                    Text('هذا الحقل مطلوب', style: AppTextStyles.errorText),
                  ],
                  SizedBox(height: 16.h),
                  Text('الكمية المتوفرة *', style: AppTextStyles.inputLabel),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: _quantityController,
                    hintText: 'أدخل الكمية المتوفرة',
                    keyboardType: TextInputType.number,
                    inputFormatters: [DigitsOnlyFormatter()],
                    prefixIcon: Icon(Icons.inventory_2_outlined, color: AppColors.grey, size: 20.sp),
                    onChanged: (value) => context.read<AddMedicineCubit>().quantityChanged(value),
                  ),
                  if (_attemptedSave && (formData.quantityValue ?? 0) <= 0) ...[
                    SizedBox(height: 6.h),
                    Text('هذا الحقل مطلوب', style: AppTextStyles.errorText),
                  ],
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('متوفر حالياً', style: AppTextStyles.inputLabel),
                      Switch(
                        value: formData.isAvailable,
                        activeThumbColor: AppColors.mainTeal,
                        onChanged: (value) =>
                            context.read<AddMedicineCubit>().isAvailableChanged(value),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  AppCustomButton(
                    text: 'إضافة الدواء',
                    isLoading: state is AddMedicineSaving,
                    backgroundColor:
                        formData.canSubmit ? AppColors.mainTeal : AppColors.borderGrey,
                    onPressed: () {
                      setState(() => _attemptedSave = true);
                      if (formData.canSubmit) {
                        context.read<AddMedicineCubit>().save();
                      }
                    },
                  ),
                  SizedBox(height: 12.h),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 55.h),
                      side: const BorderSide(color: AppColors.mainTeal),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                        color: AppColors.mainTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SuggestionsList extends StatelessWidget {
  final List<MedicineCatalogItem> suggestions;
  final ValueChanged<MedicineCatalogItem> onSelected;

  const _SuggestionsList({required this.suggestions, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      constraints: BoxConstraints(maxHeight: 200.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.borderGrey),
        itemBuilder: (context, index) {
          final item = suggestions[index];
          return ListTile(
            dense: true,
            leading: item.type != null ? _SourceBadge(type: item.type!) : null,
            title: Text(item.name, style: AppTextStyles.cardTitle.copyWith(fontSize: 14.sp)),
            subtitle: item.activeIngredient != null
                ? Text(item.activeIngredient!, style: AppTextStyles.footerText)
                : null,
            onTap: () => onSelected(item),
          );
        },
      ),
    );
  }
}

/// Mirrors the pharmacy web dashboard's "القائمة العامة"/"وزارة الصحة"
/// pills — `type` is `"medicine"` for the pharmacy's general catalog
/// (`data.medicines`) or `"moh"` for a Ministry of Health entry
/// (`data.moh_catalog`), both confirmed against a live response.
class _SourceBadge extends StatelessWidget {
  final String type;

  const _SourceBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final label = type == 'moh' ? 'وزارة الصحة' : 'القائمة العامة';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: AppColors.primaryTeal),
      ),
    );
  }
}
