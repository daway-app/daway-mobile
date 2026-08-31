import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_colors.dart';

/// A colored circle showing a person's initials (first letter of the first
/// two words of [name]) — used wherever a card represents a person without
/// a real profile photo (patient inquiries, ratings, ...).
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double size;

  const InitialsAvatar({super.key, required this.name, this.size = 40});

  static String _initialsOf(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '؟';
    if (words.length == 1) return words.first.substring(0, 1);
    return words[0].substring(0, 1) + words[1].substring(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: AppColors.lightTeal.withValues(alpha: 0.35),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initialsOf(name),
        style: TextStyle(
          fontSize: (size * 0.35).sp,
          fontWeight: FontWeight.bold,
          color: AppColors.mainTeal,
        ),
      ),
    );
  }
}
