import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

/// The quantity on a product card with its two buttons: "−" first, then the
/// number, then the filled "+" — the row reads plus, number, minus from the
/// left, as in the design.
///
/// The card around it opens the edit page when tapped, and a button is 24 small
/// — so the buttons are touchable [touchReach] above and below what is drawn,
/// and a tap on the number or between the buttons is swallowed. A thumb that
/// misses by a few pixels then does not land on the card.
class ProductQuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ProductQuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  /// How far the buttons can be touched above and below what is drawn: the row
  /// is this much taller than the 24 the buttons look, on each side. A card
  /// laying it out takes that space out of the padding around it.
  static const double touchReach = 8;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(label: 'إنقاص الكمية', isPlus: false, onTap: onDecrement),
          SizedBox(width: 3.w),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: 32.w),
            // The design sets the number about 3px below the middle of the
            // buttons; moved when drawn, so the stepper keeps its height.
            child: Transform.translate(
              offset: Offset(0, 3.1.h),
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: AppTextStyles.pharmacyProductQuantity,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          _StepButton(label: 'زيادة الكمية', isPlus: true, onTap: onIncrement),
        ],
      ),
    );
  }
}

/// A 24px square — solid blue with a white plus, or pale with a blue minus —
/// in a touch area that is taller than it (see [ProductQuantityStepper]).
class _StepButton extends StatelessWidget {
  final String label;
  final bool isPlus;
  final VoidCallback onTap;

  const _StepButton({required this.label, required this.isPlus, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final glyphColor = isPlus ? Colors.white : AppColors.mainTeal;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: label,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 24.w,
          height: 24.w + 2 * ProductQuantityStepper.touchReach.h,
          child: Center(
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: isPlus ? AppColors.mainTeal : AppColors.permissionIconBg,
                borderRadius: BorderRadius.circular(4.r),
                border: isPlus ? null : Border.all(color: AppColors.iconBlueBorder),
              ),
              // The glyph sits a pixel above the middle, as in the design.
              child: Padding(
                padding: EdgeInsets.only(bottom: 2.w),
                child: Center(child: _Glyph(color: glyphColor, isPlus: isPlus)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A plus or a minus drawn as bars, 8.3 long and 1.75 thick, so it is the
/// design's rather than an icon font's.
class _Glyph extends StatelessWidget {
  final Color color;
  final bool isPlus;

  const _Glyph({required this.color, required this.isPlus});

  @override
  Widget build(BuildContext context) {
    final length = 8.3.w;
    final thickness = 1.75.w;
    final bar = DecoratedBox(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(thickness / 2)),
    );

    return SizedBox(
      width: length,
      height: length,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(width: length, height: thickness, child: bar),
          if (isPlus) SizedBox(width: thickness, height: length, child: bar),
        ],
      ),
    );
  }
}
