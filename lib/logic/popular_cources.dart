import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/cubit/popular_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/widgets/popular_card.dart';

class PopularCourses extends StatelessWidget {
  const PopularCourses({super.key});

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final languageCode = langState is LanguageCubitLoaded
        ? langState.languageCode
        : 'en';

    return BlocBuilder<LanguageCubit, LanguageCubitState>(
      builder: (context, _) {
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
                    title: languageCode == 'ar'
                        ? course.titleAr
                        : course.titleEn,
                    rating: course.rating,
                    author: course.instructorName,
                    description: languageCode == 'ar'
                        ? course.descriptionAr
                        : course.descriptionEn,
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
