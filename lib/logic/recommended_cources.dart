import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/enrollments_cubit.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/cubit/recommended_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/services/network_service.dart';
import 'package:training/widgets/recommended_card.dart';

class RecommendedCourses extends StatelessWidget {
  const RecommendedCourses({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageCubitState>(
      builder: (context, langState) {
        final languageCode = langState is LanguageCubitLoaded
            ? langState.languageCode
            : 'en';

        return BlocBuilder<RecommendedCubit, RecommendedState>(
          builder: (context, state) {
            if (state is RecommendedLoading || state is RecommendedInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RecommendedError) {
              return Center(child: Text(state.message));
            }

            if (state is RecommendedLoaded) {
              final recommends = state.recommends;
              final courses = state.courses;

              final enrollmentsState = context.watch<EnrollmentsCubit>().state;

              final Set<int> enrolledCourseIds =
                  enrollmentsState is EnrollmentsLoaded
                  ? enrollmentsState.enrollments.map((e) => e.courseId).toSet()
                  : <int>{};

              final Map<int, CoursesModel> courseMap = {
                for (var course in courses) course.id: course,
              };

              final List<CoursesModel> recommendedCourses = recommends
                  .map((r) => courseMap[r.recommendCourse])
                  .whereType<CoursesModel>()
                  .toList();

              if (recommendedCourses.isEmpty) {
                return Center(
                  child: Text(
                    languageCode == 'ar'
                        ? 'لا توجد كورسات مقترحة'
                        : 'No recommended courses',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: languageCode == 'ar'
                          ? 'CustomArabicFont'
                          : 'CustomEnglishFont',
                    ),
                  ),
                );
              }

              return Column(
                children: recommendedCourses.map((course) {
                  final bool isEnrolled = enrolledCourseIds.contains(course.id);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: RecommendedCard(
                      descriptionAr: course.descriptionAr,
                      descriptionEn: course.descriptionEn,
                      courseId: course.id,
                      imagePath: course.thumbnail,
                      titleEn: course.titleEn,
                      titleAr: course.titleAr,
                      author: course.instructorName,
                      rating: course.rating,
                      isEnrolled: isEnrolled,
                    ),
                  );
                }).toList(),
              );
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}

