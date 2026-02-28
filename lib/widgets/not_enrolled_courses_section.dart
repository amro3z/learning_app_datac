import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/courses_cubit.dart';
import 'package:training/cubits/cubit/enrollments_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/courses_state.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/widgets/course_card.dart';
import 'package:training/helper/base.dart';
import 'package:training/services/local_notifications.dart';
import 'package:training/services/network_service.dart';

class NotEnrolledCoursesSection extends StatelessWidget {
  const NotEnrolledCoursesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final isArabic =
        langState is LanguageCubitLoaded && langState.languageCode == 'ar';

    final coursesState = context.watch<CoursesCubit>().state;
    final enrollState = context.watch<EnrollmentsCubit>().state;

    if (coursesState is! CoursesLoaded || enrollState is! EnrollmentsLoaded) {
      return const SizedBox();
    }

    final allCourses = coursesState.courses;
    final enrolledIds = enrollState.enrollments.map((e) => e.courseId).toSet();

    final notEnrolledCourses = allCourses
        .where((c) => !enrolledIds.contains(c.id))
        .toList();

    if (notEnrolledCourses.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        defaultText(
          context: context,
          text: isArabic ? "اكتشف دورات جديدة" : "Discover New Courses",
          size: 18,
          isCenter: false,
        ),
        const SizedBox(height: 12),

        ...notEnrolledCourses.map((course) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CourseCard(
              height: 310,
              imagePath: course.thumbnail,
              title: isArabic ? course.titleAr : course.titleEn,
              author: course.instructorName,
              rating: course.rating,
              description: isArabic
                  ? course.descriptionAr
                  : course.descriptionEn,
              courseId: course.id,
              isEnrolled: false,

              /// 🔥 هنا نفس منطق Recommended
              onEnrollPressed: () async {
                if (!NetworkService.isConnected) {
                  LocalNotifications.showNotification(
                    navigator: false,
                    title: isArabic ? 'مفيش نت' : 'No internet connection',
                    body: isArabic
                        ? 'تأكد من اتصالك بالإنترنت وحاول مرة تانية'
                        : 'Please check your internet connection and try again',
                  );
                  return;
                }

                final userId = context.read<UserCubit>().userId!;

                await context.read<EnrollmentsCubit>().enrollCourse(
                  courseId: course.id,
                  userId: userId,
                );

                LocalNotifications.showNotification(
                  navigator: true,
                  title: isArabic
                      ? "تم الاشتراك بنجاح"
                      : "Enrollment Successful",
                  body: isArabic
                      ? "تم الاشتراك في ${isArabic ? course.titleAr : course.titleEn}"
                      : "You enrolled in ${isArabic ? course.titleAr : course.titleEn}",
                  arguments: {
                    'imageURL': course.thumbnail,
                    'title': isArabic ? course.titleAr : course.titleEn,
                    'instructor': course.instructorName,
                    'description': isArabic
                        ? course.descriptionAr
                        : course.descriptionEn,
                    'courseId': course.id,
                  },
                );

                await context.read<EnrollmentsCubit>().getAllEnrollments(
                  userId: userId,
                );
              },
            ),
          );
        }).toList(),

        const SizedBox(height: 24),
      ],
    );
  }
}
