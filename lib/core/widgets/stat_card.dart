import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_colors.dart';
import 'app_card.dart';
import 'icon_badge.dart';

/// A compact "icon + number + label" tile used for the stat rows on the
/// pharmacy home and الاستفسارات screens — read-only unless [onTap] is
/// given, in which case it routes to wherever that stat is managed.
class StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String? sublabel;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.sublabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: AppCard(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBadge(icon: icon, color: color),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey,
              ),
            ),
            if (sublabel != null) ...[
              SizedBox(height: 1.h),
              Text(
                sublabel!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 9.5.sp, color: AppColors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lays out a row of [StatCard]s (or similar) with equal width and height,
/// via [IntrinsicHeight] — needed because inside a `ListView` a plain `Row`
/// has unbounded height, which `CrossAxisAlignment.stretch` can't fill.
class StatCardRow extends StatelessWidget {
  final List<Widget> cards;

  const StatCardRow({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) SizedBox(width: 10.w),
            Expanded(child: cards[i]),
          ],
        ],
      ),
    );
  }
}
