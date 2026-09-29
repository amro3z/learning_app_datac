import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/ui/state/cubit/courses_cubit.dart';
import 'package:training/ui/state/cubit/enrollments_cubit.dart';
import 'package:training/ui/state/cubit/language_cubit.dart';
import 'package:training/ui/state/states/courses_state.dart';
import 'package:training/ui/state/states/language_cubit_state.dart';
import 'package:training/ui/widgets/course_card.dart';
import 'package:training/ui/core/base.dart';

class NotEnrolledCoursesSection extends StatelessWidget {
  const NotEnrolledCoursesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final isArabic =
        langState is LanguageCubitLoaded && langState.languageCode == 'ar';

    final coursesState = context.watch<CoursesCubit>().state;
    final enrollState = context.watch<EnrollmentsCubit>().state;

    if (coursesState is! CoursesLoaded) {
      return const SizedBox.shrink();
    }

    final allCourses = coursesState.courses;
    final enrollments = enrollState is EnrollmentsLoaded
        ? enrollState.enrollments
        : const <dynamic>[];
    // Collapse any legacy duplicate rows to one status per course. Approved wins,
    // then pending, then rejected. New duplicates are prevented by the Cubit.
    final statusByCourse = <int, String>{};
    int rank(String s) => s == 'approved' ? 3 : (s == 'pending' ? 2 : 1);
    for (final e in enrollments) {
      final old = statusByCourse[e.courseId];
      if (old == null || rank(e.status) > rank(old)) {
        statusByCourse[e.courseId] = e.status;
      }
    }
    final approvedIds = statusByCourse.entries
        .where((e) => e.value == 'approved')
        .map((e) => e.key)
        .toSet();

    final notEnrolledCourses = allCourses
        .where((c) => !approvedIds.contains(c.id))
        .toList();

    if (notEnrolledCourses.isEmpty) {
      return SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        defaultText(
          context: context,
          text: isArabic ? "اكتشف دورات جديدة" : "Discover New Courses",
          size: getScreenWidth(context) * 0.045,
          isCenter: false,
        ),
        SizedBox(height: getScreenHeight(context) * 0.015),

        ...notEnrolledCourses.map((course) {
          return Padding(
            padding: EdgeInsets.only(bottom: getScreenHeight(context) * 0.02),
            child: CourseCard(
            
              imagePath: course.thumbnail,
              title: isArabic ? course.titleAr : course.titleEn,
              author: course.instructorName,
              rating: course.rating,
              description: isArabic
                  ? course.descriptionAr
                  : course.descriptionEn,
              courseId: course.id,
              isEnrolled: false,
              enrollmentStatus: statusByCourse[course.id],
            ),
          );
        }),

        SizedBox(height: getScreenHeight(context) * 0.005),
      ],
    );
  }
}
