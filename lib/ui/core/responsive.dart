import 'dart:math' as math;
import 'package:flutter/material.dart';

class Responsive {
  const Responsive._();

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double height(BuildContext context) => MediaQuery.sizeOf(context).height;
  static bool isCompact(BuildContext context) => width(context) < 360;
  static bool isPhone(BuildContext context) => width(context) < 600;
  static bool isTablet(BuildContext context) => width(context) >= 600;

  static double scale(BuildContext context) {
    return (width(context) / 390).clamp(.82, 1.25);
  }

  static double value(
    BuildContext context,
    double value, {
    double? min,
    double? max,
  }) {
    final scaled = value * scale(context);
    return scaled.clamp(min ?? value * .78, max ?? value * 1.28);
  }

  static EdgeInsets pagePadding(BuildContext context) {
    final w = width(context);
    if (w >= 900) return const EdgeInsets.symmetric(horizontal: 40, vertical: 24);
    if (w >= 600) return const EdgeInsets.symmetric(horizontal: 28, vertical: 20);
    return EdgeInsets.symmetric(horizontal: isCompact(context) ? 10 : 16, vertical: 16);
  }

  static double maxContentWidth(BuildContext context) {
    return math.min(width(context), 900);
  }
}
