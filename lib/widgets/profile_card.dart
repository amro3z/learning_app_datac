import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/enrollments_cubit.dart';
import 'package:training/cubits/cubit/lessons_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/states/user_state.dart';
import 'package:training/helper/base.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.state, required this.pickImage});

  final UserLoaded state;
  final Future<void> Function(BuildContext) pickImage;

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserCubit>().userId;

    int enrolledCount = 0;
    int completedCoursesCount = 0;
    double completedHours = 0;

    /// =========================
    /// ENROLLMENTS DATA
    /// =========================
    final enrollmentsState = context.watch<EnrollmentsCubit>().state;

    if (enrollmentsState is EnrollmentsLoaded && userId != null) {
      final userEnrollments = enrollmentsState.enrollments
          .where((e) => e.userId == userId)
          .toList();

      enrolledCount = userEnrollments.length;

      completedCoursesCount = userEnrollments
          .where((e) => e.progressPercent >= 100)
          .length;
    }

    /// =========================
    /// COMPLETED LESSON HOURS
    /// =========================
    final lessonsState = context.watch<LessonsCubit>().state;

    if (lessonsState is LessonsLoaded && userId != null) {
      final completedLessons = lessonsState.progress
          .where((p) => p.userId == userId && p.status == "completed")
          .toList();

      for (final lessonProgress in completedLessons) {
        final lesson = lessonsState.lessons.firstWhere(
          (l) => l.id == lessonProgress.lesson,
          orElse: () => null as dynamic,
        );

        if (lesson != null) {
          completedHours += lesson.duration / 60;
          // duration بالدقايق → نحولها لساعات
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          /// =========================
          /// USER INFO
          /// =========================
          Row(
            children: [
              GestureDetector(
                onTap: state.isUploading ? null : () => pickImage(context),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.35),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blueAccent, width: 2),
                      ),
                    ),
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: state.avatarUrl != null
                          ? NetworkImage(state.avatarUrl!)
                          : null,
                      child: state.avatarUrl == null
                          ? const Icon(Icons.person, size: 32)
                          : null,
                    ),
                    if (state.isUploading)
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    defaultText(
                      text: state.name,
                      size: 20,
                      bold: true,
                      isCenter: false,
                    ),
                    const SizedBox(height: 4),
                    defaultText(
                      text: state.email,
                      size: 14,
                      color: Colors.grey,
                      isCenter: false,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 32, color: Colors.white12),
          const SizedBox(height: 12),

          /// =========================
          /// STATS
          /// =========================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              /// ENROLLED
              Column(
                children: [
                  defaultText(
                    text: enrolledCount.toString(),
                    size: 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 4),
                  defaultText(text: "Enrolled", size: 14, color: Colors.grey),
                ],
              ),

              /// COMPLETED COURSES
              Column(
                children: [
                  defaultText(
                    text: completedCoursesCount.toString(),
                    size: 16,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 4),
                  defaultText(text: "Completed", size: 14, color: Colors.grey),
                ],
              ),

              /// HOURS
              Column(
                children: [
                  defaultText(
                    text: completedHours.toStringAsFixed(1),
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 4),
                  defaultText(text: "Hours", size: 14, color: Colors.grey),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
