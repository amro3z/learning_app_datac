import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/lessons_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
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
    required this.titleEn,
    required this.titleAr,
    required this.duration,
    required this.state,
    required this.courseID,
    required this.lessonID,
    required this.lessonDurationInSeconds,
    required this.lessonDescriptionEn,
    required this.lessonDescriptionAr,
    required this.videoURl,
    required this.courseTitle,
  });

  final String titleEn;
  final String titleAr;
  final int duration;
  final CourseStatus state;
  final int courseID;
  final int lessonID;
  final int lessonDurationInSeconds;
  final String lessonDescriptionEn;
  final String lessonDescriptionAr;
  final String videoURl;
  final String courseTitle;

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final languageCode = langState is LanguageCubitLoaded
        ? langState.languageCode
        : 'en';

    final title = languageCode == 'ar' ? titleAr : titleEn;

    final description = languageCode == 'ar'
        ? lessonDescriptionAr
        : lessonDescriptionEn;

    return GestureDetector(
      onTap: state == CourseStatus.locked
          ? null
          : () {
              Navigator.pushNamed(
                context,
                '/lesson_screen',
                arguments: {
                  'courseID': courseID,
                  'lessonID': lessonID,
                  'lessonTitle': title,
                  'lessonDescription': description,
                  'videoURl': videoURl,
                  'courseTitle': courseTitle,
                  'lessonDurationInSeconds': lessonDurationInSeconds,
                },
              );
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
                  defaultText(text: title, size: 14, isCenter: false, context: context),
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
                        context: context,
                        text: languageCode == 'ar'
                            ? "$duration دقيقة"
                            : "$duration min",
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
  const Lessons({super.key, required this.courseId, required this.courseTitle});

  final String courseTitle;
  final int courseId;

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserCubit>().userId;

    return BlocBuilder<LanguageCubit, LanguageCubitState>(
      builder: (context, langState) {
        final languageCode = langState is LanguageCubitLoaded
            ? langState.languageCode
            : 'en';

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

            final courseLessons =
                state.lessons.where((l) => l.courseId == courseId).toList()
                  ..sort((a, b) => a.id.compareTo(b.id));

            final Map<int, int> watchedSecondsMap = {
              for (var p in state.progress)
                if (p.courseId == courseId && p.userId == userId)
                  p.lesson: p.watchedSeconds,
            };

            final List<Map<String, dynamic>> ordered = [];

            for (int i = 0; i < courseLessons.length; i++) {
              final lesson = courseLessons[i];

              final watchedSeconds = watchedSecondsMap[lesson.id] ?? 0;

              final lessonDurationInSeconds = lesson.duration * 60;

              final bool isCompleted =
                  watchedSeconds >= (lessonDurationInSeconds - 60);

              CourseStatus status;

              if (i == 0) {
                status = isCompleted
                    ? CourseStatus.completed
                    : CourseStatus.present;
              } else {
                final prevStatus = ordered[i - 1]['status'] as CourseStatus;

                if (prevStatus == CourseStatus.completed) {
                  status = isCompleted
                      ? CourseStatus.completed
                      : CourseStatus.present;
                } else {
                  status = CourseStatus.locked;
                }
              }

              ordered.add({'lesson': lesson, 'status': status});
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                defaultText(
                  context: context,
                  text: languageCode == 'ar'
                      ? 'الدروس (${ordered.length})'
                      : 'Lessons (${ordered.length})',
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
                      courseID: lesson.courseId,
                      lessonID: lesson.id,
                      lessonDurationInSeconds: lesson.duration * 60,
                      lessonDescriptionEn: lesson.descriptionEn,
                      lessonDescriptionAr: lesson.descriptionAr,
                      videoURl: lesson.videoUrl,
                      courseTitle: courseTitle,
                      titleEn: lesson.titleEn,
                      titleAr: lesson.titleAr,
                      duration: lesson.duration,
                      state: status,
                    ),
                  );
                }).toList(),
              ],
            );
          },
        );
      },
    );
  }
}
