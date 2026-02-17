import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/enrollments_cubit.dart';
import 'package:training/cubits/cubit/recommended_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/helper/base.dart';

class RecommendedCard extends StatefulWidget {
  const RecommendedCard({
    super.key,
    required this.courseId,
    required this.title,
    required this.author,
    required this.rating,
    required this.imagePath,
    required this.isEnrolled,
  });

  final int courseId;
  final String title;
  final String author;
  final double rating;
  final String imagePath;
  final bool isEnrolled;

  @override
  State<RecommendedCard> createState() => _RecommendedCardState();
}

class _RecommendedCardState extends State<RecommendedCard> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.imagePath,
              height: 110,
              width: 110,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              defaultText(
                text: widget.title,
                size: 14,
                color: Colors.white,
                bold: true,
                isCenter: false,
              ),
              const SizedBox(height: 4),
              defaultText(
                text: widget.author,
                size: 12,
                color: Colors.white.withOpacity(0.6),
                isCenter: false,
              ),
              const SizedBox(height: 8),
              defaultText(text: "⭐ ${widget.rating}", size: 12),
              const SizedBox(height: 10),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildButton(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    if (widget.isEnrolled) {
      return _successButton();
    }

    if (_loading) {
      return _loadingButton();
    }

    return _enrollButton(context);
  }

  Widget _enrollButton(BuildContext context) {
    return SizedBox(
      key: const ValueKey('enroll'),
      width: 100,
      height: 32,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: _loading
            ? null
            : () async {
                if (widget.isEnrolled) return;

                setState(() => _loading = true);

                await context.read<EnrollmentsCubit>().enrollCourse(
                  courseId: widget.courseId,
                  userId: context.read<UserCubit>().userId!,
                );
                await context.read<EnrollmentsCubit>().getAllEnrollments(userId: context.read<UserCubit>().userId!);

                setState(() => _loading = false);
              },
        child: const Text('Enroll', style: TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _loadingButton() {
    return const SizedBox(
      key: ValueKey('loading'),
      width: 100,
      height: 32,
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _successButton() {
    return Container(
      key: const ValueKey('success'),
      width: 100,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(Icons.check, color: Colors.white, size: 18),
      ),
    );
  }
}


class RecommendedCourses extends StatelessWidget {
  const RecommendedCourses({super.key});

  @override
  Widget build(BuildContext context) {
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

          /// ===== ENROLLMENTS STATE =====
          final enrollmentsState = context.watch<EnrollmentsCubit>().state;

          final Set<int> enrolledCourseIds =
              enrollmentsState is EnrollmentsLoaded
                  ? enrollmentsState.enrollments
                      .map((e) => e.courseId)
                      .toSet()
                  : <int>{};

          /// ===== MAP COURSES =====
          final Map<int, CoursesModel> courseMap = {
            for (var course in courses) course.id: course,
          };

          /// ===== FILTER RECOMMENDED COURSES =====
          final List<CoursesModel> recommendedCourses = recommends
              .map((r) => courseMap[r.recommendCourse])
              .whereType<CoursesModel>()
              .toList();

          if (recommendedCourses.isEmpty) {
            return const Center(
              child: Text(
                'No recommended courses',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return Column(
            children: recommendedCourses.map((course) {
              final bool isEnrolled =
                  enrolledCourseIds.contains(course.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RecommendedCard(
                  courseId: course.id,
                  imagePath: course.thumbnail,
                  title: course.title,
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
  }
}