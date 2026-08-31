import 'package:flutter/material.dart';

import '../../../../core/theming/app_colors.dart';
import '../../domain/entities/notification.dart';

/// The icon, its color, and the Arabic title shown for a notification card —
/// the backend's `message` is already a full sentence, so only these
/// per-[NotificationType] display bits are derived client-side.
class NotificationDisplay {
  final IconData icon;
  final Color color;
  final String title;

  const NotificationDisplay({
    required this.icon,
    required this.color,
    required this.title,
  });
}

NotificationDisplay notificationDisplayFor(NotificationType type) {
  return switch (type) {
    NotificationType.outOfStock => const NotificationDisplay(
      icon: Icons.error_outline,
      color: AppColors.error,
      title: 'دواء نافد من المخزون',
    ),
    NotificationType.lowStock => const NotificationDisplay(
      icon: Icons.trending_down,
      color: AppColors.warning,
      title: 'مخزون منخفض',
    ),
    NotificationType.newInquiry => const NotificationDisplay(
      icon: Icons.chat_bubble_outline,
      color: AppColors.primaryTeal,
      title: 'استفسار جديد',
    ),
    NotificationType.newRating => const NotificationDisplay(
      icon: Icons.star_outline_rounded,
      color: AppColors.warning,
      title: 'تقييم جديد',
    ),
    NotificationType.other => const NotificationDisplay(
      icon: Icons.person_outline,
      color: AppColors.primaryTeal,
      title: 'إشعار',
    ),
  };
}
