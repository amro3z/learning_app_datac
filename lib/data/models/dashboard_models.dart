import 'package:flutter/material.dart';

class OverviewStat {
  final String value;
  final String label;
  final IconData icon;
  const OverviewStat({
    required this.value,
    required this.label,
    required this.icon,
  });
}

class CourseStatusItem {
  final String label;
  final int count;
  final double percent;
  const CourseStatusItem({
    required this.label,
    required this.count,
    required this.percent,
  });
}

class ProgressStat {
  final String value;
  final String label;
  final String change;
  final IconData icon;
  const ProgressStat({
    required this.value,
    required this.label,
    required this.change,
    required this.icon,
  });
}

class SummaryItem {
  final String title;
  final String subtitle;
  final String tag;
  final String imageUrl;
  final IconData icon;
  const SummaryItem({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.imageUrl,
    required this.icon,
  });
}
