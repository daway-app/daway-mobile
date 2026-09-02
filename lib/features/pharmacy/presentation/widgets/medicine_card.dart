import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theming/app_colors.dart';
import '../../domain/entities/medicine.dart';
import '../helpers/medicine_text_display.dart';
import 'medicine_status_badge.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onEdit,
    required this.onDelete,
  });

  bool get _hasArabicName =>
      medicine.nameAr != null && medicine.nameAr!.trim().isNotEmpty;

  /// The English catalog name — the app's only shouty-import risk (Arabic
  /// has no letter case) — shrinks when it's an all-caps import artifact,
  /// and drops to a secondary style once the Arabic name above it is
  /// already carrying the primary "this is the name" weight.
  TextStyle get _englishNameStyle {
    if (_hasArabicName) {
      return TextStyle(
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.grey,
      );
    }
    final shouty = isShoutyLatinName(medicine.name);
    return TextStyle(
      fontSize: shouty ? 13.sp : 15.sp,
      fontWeight: shouty ? FontWeight.w600 : FontWeight.bold,
      height: 1.3,
      color: AppColors.mainTeal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Spacer(),
              _IconButton(icon: Icons.edit_outlined, color: AppColors.grey, onTap: onEdit),
              SizedBox(width: 4.w),
              _IconButton(icon: Icons.delete_outline, color: AppColors.error, onTap: onDelete),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MedicineImage(imageUrl: medicine.imageUrl),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_hasArabicName) ...[
                      Text(
                        medicine.nameAr!,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          color: AppColors.mainTeal,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                    ],
                    Text(
                      medicine.name,
                      style: _englishNameStyle,
                      textAlign: TextAlign.right,
                      textDirection: textDirectionFor(medicine.name),
                      maxLines: _hasArabicName ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (medicine.activeIngredient != null && medicine.activeIngredient!.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.science_outlined, size: 12.sp, color: AppColors.grey),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              // Catalog active ingredients often arrive
                              // all-caps from an import; Arabic has no
                              // letter case, so this only ever fires for
                              // Latin script (a real mixed-case name like
                              // "Paracetamol" is untouched).
                              isShoutyLatinName(medicine.activeIngredient!)
                                  ? medicine.activeIngredient!.toLowerCase()
                                  : medicine.activeIngredient!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.grey,
                              ),
                              textAlign: TextAlign.right,
                              textDirection: textDirectionFor(medicine.activeIngredient!),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 10.h),
                    Text(
                      '${medicine.price.toStringAsFixed(2)} ${AppConstants.currencySuffix}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mainTeal,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MedicineStatusBadge(status: medicine.status),
                  SizedBox(height: 10.h),
                  Text(
                    'الكمية',
                    style: TextStyle(fontSize: 10.5.sp, color: AppColors.grey),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${medicine.quantity}',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MedicineImage extends StatelessWidget {
  final String? imageUrl;

  const _MedicineImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72.w,
      height: 72.w,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: (imageUrl != null && imageUrl!.isNotEmpty)
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.medication_outlined, color: AppColors.grey, size: 28.sp),
            )
          : Icon(Icons.medication_outlined, color: AppColors.grey, size: 28.sp),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.all(4.r),
        child: Icon(icon, size: 18.sp, color: color),
      ),
    );
  }
}
