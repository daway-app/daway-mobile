import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../domain/entities/medicine.dart';
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

  /// Prefer the Arabic trade name when the catalog has one — only falls
  /// back to the (often English) catalog [Medicine.name] when it doesn't.
  String get _displayName {
    final nameAr = medicine.nameAr;
    return (nameAr != null && nameAr.trim().isNotEmpty) ? nameAr : medicine.name;
  }

  /// Catalog trade names imported as all-caps Latin text (e.g. "KAARAL
  /// BLONDE ELEVATION...") read as shouting and wrap awkwardly at the
  /// normal title size, so they're rendered smaller. Arabic names have no
  /// letter case, so this only ever fires for Latin script.
  bool get _isShoutyName {
    final letters = _displayName.replaceAll(RegExp(r'[^A-Za-z]'), '');
    return letters.isNotEmpty && letters == letters.toUpperCase();
  }

  /// Latin text (trade names imported from an English catalog) needs its
  /// own ltr run so truncation ellipsizes on its natural trailing edge
  /// instead of the leading edge the surrounding rtl layout would put it on.
  TextDirection _textDirectionFor(String text) =>
      RegExp(r'[A-Za-z]').hasMatch(text) ? TextDirection.ltr : TextDirection.rtl;

  TextStyle get _nameStyle => TextStyle(
        fontSize: _isShoutyName ? 13.sp : 15.sp,
        fontWeight: _isShoutyName ? FontWeight.w600 : FontWeight.bold,
        height: 1.3,
        color: AppColors.mainTeal,
      );

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
                    Text(
                      _displayName,
                      style: _nameStyle,
                      textAlign: TextAlign.right,
                      textDirection: _textDirectionFor(_displayName),
                      maxLines: 2,
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
                              medicine.activeIngredient!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.grey,
                              ),
                              textAlign: TextAlign.right,
                              textDirection: _textDirectionFor(medicine.activeIngredient!),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 10.h),
                    Text(
                      '${medicine.price.toStringAsFixed(2)} ر.س',
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
