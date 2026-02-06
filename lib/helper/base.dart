import 'package:flutter/material.dart';

get getScreenWidth =>
    (BuildContext context) => MediaQuery.of(context).size.width;

get getScreenHeight =>
    (BuildContext context) => MediaQuery.of(context).size.height;

Widget defaultText({
  required String text,
  required double size,
  bool isCenter = true,
  Color? color,
  bool bold = true,
  TextAlign? align,
}) {
  return Text(
    textAlign: align ?? TextAlign.center,
    text,
    style: TextStyle(
      fontSize: size,
      fontFamily: 'CustomFont',
      color: color,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    ),
  );
}

Widget schoolSign() {
  return Container(
    width: 70,
    height: 70,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF4FACFE), Color(0xFF8F5BFF)],
      ),
      borderRadius: BorderRadius.circular(22),
    ),
    child: const Icon(Icons.school, color: Colors.white, size: 34),
  );
}

Widget progressBar({
  required double progress, // من 0.0 لـ 1.0
  double height = 10,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: constraints.maxWidth * progress,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4FACFE), // أزرق
                    Color(0xFF7B61FF), // بنفسجي
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    ),
  );
}

enum CourseStatus { completed, inProgress, locked }

const Map<CourseStatus, IconData> _icons = {
  CourseStatus.completed: Icons.check_circle,
  CourseStatus.inProgress: Icons.play_circle_fill,
  CourseStatus.locked: Icons.radio_button_unchecked,
};

const Map<CourseStatus, Color> _colors = {
  CourseStatus.completed: Colors.green,
  CourseStatus.inProgress: Colors.lightBlue,
  CourseStatus.locked: Colors.grey,
};

Widget lessonCard({
  required String title,
  required String duration,
  required CourseStatus state,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey.withOpacity(0.1),
      border: Border.all(color: Colors.white12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(_icons[state]!, color: _colors[state], size: 30),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            defaultText(text: title, size: 14, isCenter: false),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.access_time_sharp,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                defaultText(
                  text: duration,
                  size: 12,
                  isCenter: false,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

Widget ratingWidget({required double value}) {
  return Row(
    children: [
      ...List.generate(
        5,
        (index) => Icon(
          index < value.floor() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        ),
      ),
      const SizedBox(width: 6),
      defaultText(text: value.toString(), bold: false, size: 12),
    ],
  );
}
