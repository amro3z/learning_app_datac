import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:training/cubits/cubit/enrollments_cubit.dart';
import 'package:training/cubits/cubit/lessons_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/cubits/states/user_state.dart';
import 'package:training/helper/base.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.state, required this.pickImage});

  final UserLoaded state;
  final Future<void> Function(BuildContext) pickImage;

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserCubit>().userId;

    final langState = context.watch<LanguageCubit>().state;
    final isArabic =
        langState is LanguageCubitLoaded && langState.languageCode == 'ar';

    int enrolledCount = 0;
    int completedCoursesCount = 0;
    double completedHours = 0;

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

    final lessonsState = context.watch<LessonsCubit>().state;

    if (lessonsState is LessonsLoaded && userId != null) {
      final completedLessons = lessonsState.progress
          .where((p) => p.userId == userId && p.status == "completed")
          .toList();

      for (final lessonProgress in completedLessons) {
        final lesson = lessonsState.lessons
            .where((l) => l.id == lessonProgress.lesson)
            .firstOrNull;

        if (lesson != null) {
          completedHours += lesson.duration / 60;
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
          Row(
            children: [
              GestureDetector(
                onTap: state.isUploading ? null : () => pickImage(context),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: ClipOval(
                    child: state.avatarUrl == null
                        ? Container(
                            color: Colors.white10,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.person,
                              size: 32,
                              color: Colors.white70,
                            ),
                          )
                        : Image.network(
                            state.avatarUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: Colors.white10,
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stack) {
                              return Container(
                                color: Colors.white10,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.person,
                                  size: 32,
                                  color: Colors.white70,
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    defaultText(
                      context: context,
                      text: state.name,
                      size: 20,
                      isCenter: false,
                    ),
                    const SizedBox(height: 4),
                    defaultText(
                      context: context,
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
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem(
                context,
                enrolledCount.toString(),
                isArabic ? "المسجل" : "Enrolled",
                Colors.blue,
              ),
              _statItem(
                context,
                completedCoursesCount.toString(),
                isArabic ? "المكتمل" : "Completed",
                Colors.purple,
              ),
              _statItem(
                context,
                completedHours.toStringAsFixed(1),
                isArabic ? "ساعات" : "Hours",
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        defaultText(context: context, text: value, size: 16, color: color),
        const SizedBox(height: 4),
        defaultText(
          context: context,
          text: label,
          size: 14,
          color: Colors.grey,
        ),
      ],
    );
  }
}
