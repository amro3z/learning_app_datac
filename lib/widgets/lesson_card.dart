import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/lessons_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/data/models/lessons.dart';
import 'package:training/helper/base.dart';

enum CourseStatus { completed, present, locked }

const Map<CourseStatus, IconData> _icons = {
  CourseStatus.completed: Icons.check_circle,
  CourseStatus.present: Icons.play_circle_fill,
  CourseStatus.locked: Icons.radio_button_unchecked,
};

const Map<CourseStatus, Color> _colors = {
  CourseStatus.completed: Colors.green,
  CourseStatus.present: Colors.lightBlue,
  CourseStatus.locked: Colors.grey,
};

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.title,
    required this.duration,
    required this.state,
  });

  final String title;
  final int duration;
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
            Expanded(
              child: Column(
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
                        text: "$duration min",
                        size: 12,
                        isCenter: false,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Lessons extends StatelessWidget {
  const Lessons({super.key, required this.courseId});

  final int courseId;

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserCubit>().userId;

    return BlocBuilder<LessonsCubit, LessonsState>(
      builder: (context, state) {
        if (state is LessonsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is LessonsError) {
          return Center(child: Text(state.message));
        }

        if (state is! LessonsLoaded) {
          return const SizedBox.shrink();
        }

        /// 1️⃣ دروس الكورس فقط
        final courseLessons = state.lessons
            .where((l) => l.courseId == courseId)
            .toList();

        /// 2️⃣ progress خاص باليوزر الحالي فقط
        final Map<int, String> progressMap = {
          for (var p in state.progress)
            if (p.courseId == courseId && p.userId == userId)
              p.lesson: p.status,
        };

        /// 3️⃣ تحديد الحالات
        final List<Map<String, dynamic>> ordered = [];
        bool openedLessonFound = false;

        for (final lesson in courseLessons) {
          final progressStatus = progressMap[lesson.id];

          CourseStatus status;

          if (progressStatus == 'completed') {
            status = CourseStatus.completed;
          } else if (progressStatus == 'present' && !openedLessonFound) {
            status = CourseStatus.present;
            openedLessonFound = true;
          } else {
            status = CourseStatus.locked;
          }

          ordered.add({'lesson': lesson, 'status': status});
        }

        /// 4️⃣ ترتيب (completed → present → locked)
        int order(CourseStatus s) {
          switch (s) {
            case CourseStatus.completed:
              return 0;
            case CourseStatus.present:
              return 1;
            case CourseStatus.locked:
              return 2;
          }
        }

        ordered.sort(
          (a, b) => order(a['status']).compareTo(order(b['status'])),
        );

        /// 5️⃣ UI
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            defaultText(
              text: 'Lessons (${ordered.length})',
              size: 18,
              isCenter: false,
            ),
            const SizedBox(height: 8),
            ...ordered.map((item) {
              final lesson = item['lesson'] as LessonModel;
              final status = item['status'] as CourseStatus;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LessonCard(
                  title: lesson.title,
                  duration: lesson.duration,
                  state: status,
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
