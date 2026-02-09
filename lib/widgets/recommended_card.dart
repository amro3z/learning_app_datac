import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/recommended_cubit.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/helper/base.dart';
import 'package:training/helper/custom_glow_buttom.dart';

class RecommendedCard extends StatelessWidget {
  const RecommendedCard({super.key , required this.title , required this.author , required this.rating , required this.imagePath});
final String title;
final String author;
final double rating;
final String imagePath;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imagePath,
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
                text: title,
                size: 14,
                color: Colors.white,
                bold: true,
                isCenter: false,
              ),
              const SizedBox(height: 4),
              defaultText(
                text: author,
                size: 12,
                color: Colors.white.withOpacity(0.6),
                bold: false,
                isCenter: false,
              ),
              const SizedBox(height: 8),
              defaultText(text: "⭐ $rating", size: 12),
              const SizedBox(height: 8),
              CustomGlowButton(
                title: 'Enroll Now',
                onPressed: () {
                  Navigator.pushNamed(context, '/course_details');
                },
                textSize: 12,
                width: 80,
              ),
            ],
          ),
        ],
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

          final Map<int, CoursesModel> courseMap = {
            for (var course in courses) course.id: course,
          };

          final List<CoursesModel> recommendedCourses = recommends
              .map((e) => courseMap[e.recommendCourse])
              .whereType<CoursesModel>()
              .toList();

          return Column(
            children: recommendedCourses.map((course) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RecommendedCard(
                  imagePath: course.thumbnail,
                  title: course.title,
                  author: course.instructorName,
                  rating: course.rating,
                ),
              );
            }).toList(),
          );
        }

        return const SizedBox.shrink();
      },
    ) ;
  }
}