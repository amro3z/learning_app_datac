import 'package:flutter/material.dart';
import 'package:training/helper/base.dart';
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

class LessonCard extends StatelessWidget {
  const LessonCard({super.key ,   
  required this.title,
    required this.duration,
    required this.state,
  });
  final String title;
  final String duration;  
  final CourseStatus state;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: state == CourseStatus.locked
          ? null
          : () {
              Navigator.pushNamed(context, '/lesson_screen');
            },
      child: Container(
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
      ),
    );
  }
}
