import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

/// The products page's search box: an outlined 56px field with the search icon
/// at its start. Owns its text controller, starting from [initialText] — so a
/// field that is built again (the page went back to loading, then loaded) shows
/// the query the list is filtered by.
class ProductSearchField extends StatefulWidget {
  final String initialText;
  final ValueChanged<String> onChanged;

  const ProductSearchField({super.key, this.initialText = '', required this.onChanged});

  @override
  State<ProductSearchField> createState() => _ProductSearchFieldState();
}

class _ProductSearchFieldState extends State<ProductSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      // 16 from the edge of the field, of which the border is one.
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/Search_icon.svg',
            width: 24.w,
            height: 24.w,
            colorFilter: const ColorFilter.mode(AppColors.mainTeal, BlendMode.srcIn),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.mainTeal,
              style: AppTextStyles.pharmacySearchText,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'ابحث',
                hintStyle: AppTextStyles.pharmacySearchText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
