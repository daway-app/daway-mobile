import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A box with a rounded, dashed border — Flutter has no built-in dashed
/// border. The stroke is drawn inside the box's bounds (like a CSS
/// `border: 1px dashed`), so the box keeps exactly the size its parent gives it.
class DashedBorderBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color? backgroundColor;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  const DashedBorderBox({
    super.key,
    required this.child,
    required this.color,
    this.backgroundColor,
    this.radius = 0,
    this.strokeWidth = 1,
    this.dashLength = 8,
    this.gapLength = 8,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        backgroundColor: backgroundColor,
        radius: radius,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        gapLength: gapLength,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final Color? backgroundColor;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  const _DashedBorderPainter({
    required this.color,
    required this.backgroundColor,
    required this.radius,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final box = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));

    final fill = backgroundColor;
    if (fill != null) canvas.drawRRect(box, Paint()..color = fill);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final path = Path()..addRRect(box.deflate(strokeWidth / 2));

    // A dash pattern that cannot advance (ScreenUtil scales every `.w` to 0
    // for a frame if the view has no size yet) would loop forever below, so
    // draw the outline solid instead.
    final period = dashLength + gapLength;
    if (!(dashLength > 0 && period > 0)) {
      canvas.drawPath(path, stroke);
      return;
    }

    for (final metric in path.computeMetrics()) {
      for (var start = 0.0; start < metric.length; start += period) {
        final end = math.min(start + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(start, end), stroke);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor ||
        radius != oldDelegate.radius ||
        strokeWidth != oldDelegate.strokeWidth ||
        dashLength != oldDelegate.dashLength ||
        gapLength != oldDelegate.gapLength;
  }
}
