import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/ui/state/cubit/language_cubit.dart';
import 'package:training/ui/state/cubit/lessons_cubit.dart';
import 'package:training/ui/state/cubit/user_cubit.dart';
import 'package:training/ui/state/cubit/enrollments_cubit.dart';
import 'package:training/ui/state/states/language_cubit_state.dart';
import 'package:training/data/models/lessons.dart';
import 'package:training/ui/core/base.dart';
import 'package:training/ui/widgets/lesson_card.dart';

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
              return Center(child: CircularProgressIndicator());
            }

            if (state is LessonsError) {
              return Center(child: Text(state.message));
            }

            if (state is! LessonsLoaded) {
              return SizedBox.shrink();
            }

            final courseLessons =
                state.lessons.where((l) => l.courseId == courseId).toList()
                  ..sort((a, b) => a.id.compareTo(b.id));

            final enrollmentState = context.watch<EnrollmentsCubit>().state;
            final completedLessonIds = <int>{};
            if (enrollmentState is EnrollmentsLoaded) {
              for (final enrollment in enrollmentState.enrollments) {
                if (enrollment.courseId == courseId &&
                    enrollment.userId == userId &&
                    enrollment.isApproved) {
                  completedLessonIds.addAll(enrollment.completedLessonIds);
                }
              }
            }

            final List<Map<String, dynamic>> ordered = [];
            for (final lesson in courseLessons) {
              final isCompleted = completedLessonIds.contains(lesson.id);
              ordered.add({
                'lesson': lesson,
                'status': isCompleted ? CourseStatus.completed : CourseStatus.present,
              });
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
                SizedBox(height: getScreenHeight(context) * 0.01000),
                ...ordered.map((item) {
                  final lesson = item['lesson'] as LessonModel;
                  final status = item['status'] as CourseStatus;

                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
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
                      pdf: lesson.pdf,
                      state: status,
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }
}
