import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/popular_cubit.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/helper/base.dart';

class PopularCard extends StatelessWidget {
  const PopularCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.rating,
    required this.author,
    required this.description,
    required this.courseId,
  });

  final String imageUrl;
  final String title;
  final double rating;
  final String author;
  final String description;
  final int courseId;
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/course_details',
          arguments: {
            'imageURL': imageUrl,
            'title': title,
            'instructor': author,
            'description': description,
            'courseId': courseId,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          border: Border.all(color: Colors.white12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  defaultText(
                    context: context,
                    text: title,
                    size: 16,
                    color: Colors.white,
                    bold: true,
                    isCenter: false,
                  ),
                  const SizedBox(height: 4),
                  defaultText(
                    context: context,
                    text: author,
                    size: 14,
                    bold: false,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 4),
                  defaultText(
                    text: "⭐ $rating",
                    size: 14,
                    bold: false,
                    context: context,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PopularCourses extends StatelessWidget {
  const PopularCourses({super.key});

  @override
  Widget build(BuildContext context) {
        final langState = context.watch<LanguageCubit>().state;
    final languageCode = langState is LanguageCubitLoaded
        ? langState.languageCode
        : 'en';
    return BlocBuilder<LanguageCubit, LanguageCubitState>(
      builder: (context, langState) {
        return BlocBuilder<PopularCubit, PopularState>(
          builder: (context, state) {
            if (state is PopularLoading || state is PopularInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PopularError) {
              return Center(child: Text(state.errorMessage));
            }

            if (state is PopularLoaded) {
              final popularList = state.popularList;
              final courses = state.courses;

              final Map<int, CoursesModel> courseMap = {
                for (var course in courses) course.id: course,
              };

              final List<CoursesModel> popularCourses = popularList
                  .map((e) => courseMap[e.course])
                  .whereType<CoursesModel>()
                  .toList();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: popularCourses.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final course = popularCourses[index];

                  return PopularCard(
                    imageUrl: course.thumbnail,
                    title: languageCode == 'ar' ? course.titleAr : course.titleEn,
                    rating: course.rating,
                    author: course.instructorName,
                    description: languageCode == 'ar' ? course.descriptionAr : course.descriptionEn,
                    courseId: course.id,
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}
