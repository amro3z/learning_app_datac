import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/cubit/lessons_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/data/models/lessons.dart';
import 'package:training/helper/base.dart';
import 'package:training/widgets/lesson_card.dart';

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
                  size: getScreenWidth(context) * 0.045,
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
