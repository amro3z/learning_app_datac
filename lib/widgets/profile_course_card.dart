import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/enrollments_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/helper/base.dart';

class ProfileCourseCard extends StatelessWidget {
  const ProfileCourseCard({super.key , required this.title , required this.progress , required this.imageUrl});
final String title;
final String progress;
final String imageUrl;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(12),
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
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    defaultText(
                      text: title,
                      size: 14,
                      color: Colors.white,
                      bold: true,
                      isCenter: false,
                    ),
                    const SizedBox(height: 4),
                    defaultText(
                      text: progress,
                      size: 12,
                      color: Colors.grey,
                      bold: false,
                      isCenter: false,
                    ),
                  ],
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 30),
              ],
            ),
            const SizedBox(height: 12),
            progressBar(progress: double.parse(progress.replaceAll('%', '')) / 100),
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

    return BlocBuilder<EnrollmentsCubit, EnrollmentsState>(
      builder: (context, state) {
        if (state is EnrollmentsLoading || state is EnrollmentsInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is EnrollmentsError) {
          return Center(child: Text(state.message));
        }

        if (state is EnrollmentsLoaded && userId != null) {
          /// فلترة انروولمنتس المستخدم الحالي
          final userEnrollments = state.enrollments
              .where((e) => e.userId == userId)
              .toList();

          if (userEnrollments.isEmpty) {
            return const Center(
              child: Text(
                "No enrolled courses yet",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final courseMap = {for (var c in state.courses) c.id: c};

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              defaultText(
                text: "My Courses (${userEnrollments.length})",
                size: 16,
              ),

              const SizedBox(height: 12),

              ...userEnrollments.map((e) {
                final course = courseMap[e.courseId];
                if (course == null) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ProfileCourseCard(
                    imageUrl: course.thumbnail,
                    title: course.title,
                    progress: "${e.progressPercent.toStringAsFixed(0)}%",
                  ),
                );
              }).toList(),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

