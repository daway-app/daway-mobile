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
import '../../domain/entities/medicine.dart';
import '../cubit/edit_medicine_cubit.dart';
import '../cubit/edit_medicine_state.dart';

/// Only the pharmacy's own stock fields (price, quantity, availability) are
/// editable here — the trade name and active ingredient belong to the
/// shared catalog entry, so they're shown for context only.
class EditMedicineScreen extends StatefulWidget {
  final Medicine medicine;

  const EditMedicineScreen({super.key, required this.medicine});

  @override
  State<EditMedicineScreen> createState() => _EditMedicineScreenState();
}

class _EditMedicineScreenState extends State<EditMedicineScreen> {
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  bool _attemptedSave = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.medicine.price.toStringAsFixed(2));
    _quantityController = TextEditingController(text: widget.medicine.quantity.toString());
  }

  @override
  void dispose() {
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
    final activeIngredient = widget.medicine.activeIngredient;

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
          'تعديل الدواء',
          style: AppTextStyles.screenTitle.copyWith(color: AppColors.mainTeal, fontSize: 20.sp),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<EditMedicineCubit, EditMedicineState>(
          listener: (context, state) {
            if (state is EditMedicineFailure) {
              AppSnackbar.show(context, state.message);
            }
            if (state is EditMedicineSuccess) {
              Navigator.of(context).pop(true);
            }
          },
          builder: (context, state) {
            final formData = state.formData;
            _syncController(_priceController, formData.price);
            _syncController(_quantityController, formData.quantity);

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('الاسم التجاري', style: AppTextStyles.inputLabel),
                  SizedBox(height: 8.h),
                  _ReadOnlyInfoField(
                    icon: Icons.medication_outlined,
                    value: widget.medicine.displayName,
                  ),
                  if (activeIngredient != null && activeIngredient.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    Text('المادة الفعالة', style: AppTextStyles.inputLabel),
                    SizedBox(height: 8.h),
                    _ReadOnlyInfoField(icon: Icons.science_outlined, value: activeIngredient),
                  ],
                  SizedBox(height: 16.h),
                  Text('السعر *', style: AppTextStyles.inputLabel),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: _priceController,
                    hintText: 'أدخل السعر',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                    prefixIcon: Icon(Icons.sell_outlined, color: AppColors.grey, size: 20.sp),
                    onChanged: (value) => context.read<EditMedicineCubit>().priceChanged(value),
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
                    onChanged: (value) => context.read<EditMedicineCubit>().quantityChanged(value),
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
                            context.read<EditMedicineCubit>().isAvailableChanged(value),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  AppCustomButton(
                    text: 'حفظ التعديلات',
                    isLoading: state is EditMedicineSaving,
                    backgroundColor:
                        formData.canSubmit ? AppColors.mainTeal : AppColors.borderGrey,
                    onPressed: () {
                      setState(() => _attemptedSave = true);
                      if (formData.canSubmit) {
                        context.read<EditMedicineCubit>().save();
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

class _ReadOnlyInfoField extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ReadOnlyInfoField({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.grey, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16.sp, color: AppColors.textDark),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
