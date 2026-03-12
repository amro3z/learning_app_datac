import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/enrollments_cubit.dart';
import 'package:training/cubits/cubit/favorites_cubit.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/data/models/favorites.dart';
import 'package:training/helper/base.dart';
import 'package:training/widgets/course_card.dart';

class EnrollmentCourse extends StatelessWidget {
  const EnrollmentCourse({super.key});

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final languageCode = langState is LanguageCubitLoaded
        ? langState.languageCode
        : 'en';

    return BlocBuilder<EnrollmentsCubit, EnrollmentsState>(
      builder: (context, state) {
        if (state is EnrollmentsLoading || state is EnrollmentsInitial) {
          return const SizedBox.shrink();
        }

        if (state is EnrollmentsError) {
          return const SizedBox.shrink();
        }

        if (state is EnrollmentsLoaded) {
          if (state.enrollments.isEmpty) {
            return const SizedBox.shrink();
          }

          final favoritesState = context.watch<FavoritesCubit>().state;

          final favorites = favoritesState is FavoritesLoaded
              ? favoritesState.favoritesList
              : [];

          final courseMap = {for (var c in state.courses) c.id: c};

          final uniqueEnrollments = {
            for (var e in state.enrollments) e.courseId: e,
          };

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              defaultText(
                context: context,
                text: languageCode == 'ar'
                    ? 'استكمل التعلم'
                    : 'Continue Learning',
                size: getScreenWidth(context) * 0.045,
              ),

              SizedBox(height: getScreenHeight(context) * 0.015),

              ...uniqueEnrollments.values.map((e) {
                final course = courseMap[e.courseId]!;

                final fav = favorites
                    .where((f) => f.courseId == course.id)
                    .cast<FavoritesModel?>()
                    .firstOrNull;

                final isFavorite = fav != null;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: getScreenHeight(context) * 0.02,
                  ),
                  child: CourseCard(
                    imagePath: course.thumbnail,
                    title: languageCode == 'ar'
                        ? course.titleAr
                        : course.titleEn,
                    author: course.instructorName,
                    rating: course.rating,
                    progress: e.progressPercent / 100,
                    description: languageCode == 'ar'
                        ? course.descriptionAr
                        : course.descriptionEn,
                    isFavorite: isFavorite,
                    courseId: course.id,
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
