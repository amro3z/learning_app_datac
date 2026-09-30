import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/ui/state/cubit/enrollments_cubit.dart';
import 'package:training/ui/state/cubit/language_cubit.dart';
import 'package:training/ui/state/cubit/lessons_cubit.dart';
import 'package:training/ui/state/states/language_cubit_state.dart';
import 'package:training/ui/core/base.dart';
import 'package:training/ui/widgets/course_card.dart';

class FavoriteCourses extends StatelessWidget {
  final List<dynamic> courses;
  final List<int> uniqueCourseIds;

  const FavoriteCourses({
    super.key,
    required this.courses,
    required this.uniqueCourseIds,
  });

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;

    final languageCode = langState is LanguageCubitLoaded
        ? langState.languageCode
        : 'en';

    if (uniqueCourseIds.isEmpty) {
      return Center(
        child: Text(
          languageCode == 'ar' ? 'لا يوجد مفضلات بعد' : 'No favorites yet',
          style: TextStyle(
            color: Colors.white70,
            fontFamily: languageCode == 'ar'
                ? 'CustomArabicFont'
                : 'CustomEnglishFont',
          ),
        ),
      );
    }

    final courseMap = {for (var course in courses) course.id: course};

    final enrollmentsState = context.watch<EnrollmentsCubit>().state;

    final lessonsState = context.watch<LessonsCubit>().state;
    final progressMap = enrollmentsState is EnrollmentsLoaded && lessonsState is LessonsLoaded
        ? {
            for (var enrollment in enrollmentsState.enrollments.where((e) => e.isApproved))
              enrollment.courseId: enrollment.progressFor(
                lessonsState.lessons.where((l) => l.courseId == enrollment.courseId).length,
              ),
          }
        : <int, double>{};

    final enrolledIds = enrollmentsState is EnrollmentsLoaded
        ? enrollmentsState.enrollments
              .where((enrollment) => enrollment.isApproved)
              .map((enrollment) => enrollment.courseId)
              .toSet()
        : <int>{};

    return Column(
      children: uniqueCourseIds.map((courseId) {
        final course = courseMap[courseId];

        if (course == null) {
          return const SizedBox.shrink();
        }

        final progress = progressMap[courseId] ?? 0.0;

        final isEnrolled = enrolledIds.contains(courseId);

        return Padding(
          padding: EdgeInsets.only(bottom: getScreenHeight(context) * 0.02000),
          child: CourseCard(
            imagePath: course.thumbnail,

            title: languageCode == 'ar' ? course.titleAr : course.titleEn,

            author: course.instructorName,

            courseId: course.id,

            rating: course.rating,

            description: languageCode == 'ar'
                ? course.descriptionAr
                : course.descriptionEn,

            progress: progress,

            isFavorite: true,

            isEnrolled: isEnrolled,
          ),
        );
      }).toList(),
    );
  }
}
