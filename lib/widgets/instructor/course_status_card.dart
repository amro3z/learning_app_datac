import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:training/data/models/dashboard_models.dart';
import 'package:training/helper/base.dart';

class CourseStatusCard extends StatelessWidget {
  final List<CourseStatusItem> items;
  final int total;

  const CourseStatusCard({
    super.key,
    required this.items,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    const colors = [Color(0xFF6C36E8), Color(0xFF278BFF), Color(0xFFFF8A1F)];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final chartSize = responsiveWidth(
          context,
          compact ? 0.28 : 0.30,
          min: 92,
          max: 118,
        );

        final chart = SizedBox(
          width: chartSize,
          height: chartSize,
          child: CustomPaint(
            painter: _DonutPainter(
              values: items.map((e) => e.percent).toList(),
              colors: colors,
              strokeWidth: chartSize * 0.18,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  defaultText(
                    text: '$total',
                    bold: true,
                    size: responsiveWidth(context, 0.052, min: 17, max: 22),
                    color: Colors.white,
                    context: context,
                    maxLines: 1,
                  ),
                  defaultText(
                    text: 'Total',
                    bold: false,
                    size: responsiveWidth(context, 0.024, min: 8, max: 10),
                    color: Colors.white.withOpacity(.45),
                    context: context,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
        );

        final legend = Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(items.length, (index) {
            final item = items[index];
            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: getScreenHeight(context) * 0.006,
              ),
              child: Row(
                children: [
                  Container(
                    width: getScreenWidth(context) * 0.018,
                    height: getScreenWidth(context) * 0.018,
                    decoration: BoxDecoration(
                      color: colors[index],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: getScreenWidth(context) * 0.02),
                  Expanded(
                    child: defaultText(
                      text: item.label,
                      bold: false,
                      size: responsiveWidth(context, 0.026, min: 9, max: 11),
                      color: Colors.white.withOpacity(.72),
                      context: context,
                      isCenter: false,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(width: getScreenWidth(context) * 0.015),
                  defaultText(
                    text: '${item.count} (${item.percent.toStringAsFixed(1)}%)',
                    bold: false,
                    size: responsiveWidth(context, 0.023, min: 8, max: 10),
                    color: Colors.white.withOpacity(.72),
                    context: context,
                    maxLines: 1,
                  ),
                ],
              ),
            );
          }),
        );

        return Container(
          padding: EdgeInsets.all(getScreenWidth(context) * 0.035),
          decoration: BoxDecoration(
            color: const Color(0xFF111114),
            borderRadius: BorderRadius.circular(getScreenWidth(context) * 0.035),
          ),
          child: compact
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    chart,
                    SizedBox(height: getScreenHeight(context) * 0.012),
                    legend,
                  ],
                )
              : Row(
                  children: [
                    chart,
                    SizedBox(width: getScreenWidth(context) * 0.04),
                    Expanded(child: legend),
                  ],
                ),
        );
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double strokeWidth;

  _DonutPainter({
    required this.values,
    required this.colors,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / 100) * math.pi * 2;
      paint.color = colors[i];
      canvas.drawArc(rect.deflate(strokeWidth / 2), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.strokeWidth != strokeWidth;
  }
}
