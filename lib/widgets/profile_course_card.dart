import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/enrollments_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/helper/base.dart';

class ProfileCourseCard extends StatelessWidget {
  const ProfileCourseCard({
    super.key,
    required this.titleEn,
    required this.titleAr,
    required this.progress,
    required this.imageUrl,
  });

  final String titleEn;
  final String titleAr;
  final String progress;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final languageCode = langState is LanguageCubitLoaded
        ? langState.languageCode
        : 'en';

    final title = languageCode == 'ar' ? titleAr : titleEn;

    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(getScreenWidth(context) * 0.03077),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          border: Border.all(color: Colors.white12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    height: getScreenHeight(context) * 0.07500,
                    width: getScreenWidth(context) * 0.15385,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: getScreenWidth(context) * 0.03077),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    defaultText(
                                              context: context,
                      text: title,
                      size: getScreenWidth(context) * 0.03590,
                      color: Colors.white,
                      bold: true,
                      isCenter: false,
                    ),
                    SizedBox(height: getScreenHeight(context) * 0.00500),
                    defaultText(
                                              context: context,
                      text: progress,
                      size: getScreenWidth(context) * 0.03077,
                      color: Colors.grey,
                      bold: false,
                      isCenter: false,
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: getScreenWidth(context) * 0.05128,
                ),
              ],
            ),
            SizedBox(height: getScreenHeight(context) * 0.01500),
            progressBar(
              context: context,
              progress: double.parse(progress.replaceAll('%', '')) / 100,
            ),
          ],
        ),
      ),
    );
  }
}

class EnrollmentProfileCourse extends StatelessWidget {
  const EnrollmentProfileCourse({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserCubit>().userId;

    return BlocBuilder<LanguageCubit, LanguageCubitState>(
      builder: (context, langState) {
        final languageCode = langState is LanguageCubitLoaded
            ? langState.languageCode
            : 'en';

        return BlocBuilder<EnrollmentsCubit, EnrollmentsState>(
          builder: (context, state) {
            if (state is EnrollmentsLoading || state is EnrollmentsInitial) {
              return Center(child: CircularProgressIndicator());
            }

            if (state is EnrollmentsError) {
              return Center(child: Text(state.message));
            }

            if (state is EnrollmentsLoaded && userId != null) {
              final userEnrollments = state.enrollments
                  .where((e) => e.userId == userId)
                  .toList();

              if (userEnrollments.isEmpty) {
                return Center(
                  child: Text(
                    languageCode == 'ar'
                        ? "لا يوجد كورسات مسجلة بعد"
                        : "No enrolled courses yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              final courseMap = {for (var c in state.courses) c.id: c};

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  defaultText(
                                            context: context,
                    text: languageCode == 'ar'
                        ? "كورساتي (${userEnrollments.length})"
                        : "My Courses (${userEnrollments.length})",
                    size: getScreenWidth(context) * 0.04103,
                  ),
                  SizedBox(height: getScreenHeight(context) * 0.01500),
                  ...userEnrollments.map((e) {
                    final course = courseMap[e.courseId];
                    if (course == null) {
                      return SizedBox.shrink();
                    }

                    return Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: ProfileCourseCard(
                        imageUrl: course.thumbnail,
                        titleEn: course.titleEn,
                        titleAr: course.titleAr,
                        progress: "${e.progressPercent.toStringAsFixed(0)}%",
                      ),
                    );
                  }).toList(),
                ],
              );
            }

            return SizedBox.shrink();
          },
        );
      },
    );
  }
}
