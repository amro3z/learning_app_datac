import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/enrollments_cubit.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/helper/base.dart';

class CourseCard extends StatefulWidget {
  final String title;
  final String author;
  final double rating;
  final double progress;
  final String imagePath;
  const CourseCard({
    super.key,
    required this.title,
    required this.author,
    required this.rating,
    required this.progress,
    required this.imagePath,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/course_details');
      },
      child: Container(
        height: 265,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    widget.imagePath,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                // Favorite (Local only)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  defaultText(
                    text: widget.title,
                    size: 16,
                    color: Colors.white,
                    bold: true,
                    isCenter: false,
                  ),
                  const SizedBox(height: 4),
                  defaultText(
                    text: widget.author,
                    size: 13,
                    color: Colors.white.withOpacity(0.6),
                    isCenter: false,
                  ),
                  const SizedBox(height: 8),
                  ratingWidget(value: widget.rating),
                  const SizedBox(height: 10),
                  progressBar(progress: widget.progress),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EnrollmentCourse extends StatelessWidget {
  const EnrollmentCourse({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EnrollmentsCubit, EnrollmentsState>(
      builder: (context, state) {
        if (state is EnrollmentsLoading || state is EnrollmentsInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is EnrollmentsError) {
          return Center(child: Text(state.message));
        }

        if (state is EnrollmentsLoaded) {
          final enrollments = state.enrollments;
          final courses = state.courses;

          // ربط صح بالـ ID
          final Map<int, CoursesModel> courseMap = {
            for (var course in courses) course.id: course,
          };

          final List<CoursesModel> enrolledCourses = enrollments
              .map((e) => courseMap[e.courseId])
              .whereType<CoursesModel>()
              .toList();

          return Column(
            children: enrolledCourses.map((course) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CourseCard(
                  imagePath: course.thumbnail,
                  title: course.title,
                  author: course.instructorName,
                  rating: course.rating,
                  progress: course.progress / 100,
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
