import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_colors.dart';

/// A read-only row of 5 stars for [rating] (0–5, fractional allowed — e.g.
/// 4.7 renders 4 full stars and one half star). Shared by the ratings
/// summary header (fractional average) and each review card (a whole
/// number of stars) so both render identical star glyphs.
class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 16,
    this.color = AppColors.warning,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      // Pinned left-to-right regardless of the app's RTL locale — a star
      // rating is a graphical convention users read the same way in every
      // language (filled stars first), not flowing text that should mirror.
      textDirection: TextDirection.ltr,
      children: List.generate(5, (index) {
        final diff = rating - index;
        final icon = diff >= 1
            ? Icons.star_rounded
            : diff >= 0.5
            ? Icons.star_half_rounded
            : Icons.star_border_rounded;
        return Icon(icon, size: size.sp, color: color);
      }),
    );
  }
}
