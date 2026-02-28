import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/enrollments_cubit.dart';
import 'package:training/cubits/cubit/favorites_cubit.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/widgets/course_card.dart';

class FavoriteCourses extends StatelessWidget {
  const FavoriteCourses({super.key});

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final languageCode = langState is LanguageCubitLoaded
        ? langState.languageCode
        : 'en';

    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favState) {
        if (favState is FavoritesLoading || favState is FavoritesInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (favState is FavoritesError) {
          return Center(child: Text(favState.message));
        }

        final loaded = favState as FavoritesLoaded;

        if (loaded.favoritesList.isEmpty) {
          return Center(
            child: Text(
              languageCode == 'ar' ? 'لا يوجد مفضلات بعد' : 'No favorites yet',
              style: TextStyle(
                color: Colors.white70,
                fontFamily: languageCode == 'ar'
                    ? 'CustomArabicFont'
                    : 'CustomEnglishFont',
              ),
            ),
          );
        }

        final courseMap = {for (var c in loaded.courses) c.id: c};

        final uniqueFavorites = {
          for (var fav in loaded.favoritesList) fav.courseId: fav,
        };

        final enrollmentsState = context.watch<EnrollmentsCubit>().state;

        final progressMap = enrollmentsState is EnrollmentsLoaded
            ? {
                for (var e in enrollmentsState.enrollments)
                  e.courseId: e.progressPercent / 100,
              }
            : {};

        return Column(
          children: uniqueFavorites.values.map((fav) {
            final course = courseMap[fav.courseId];
            if (course == null) return const SizedBox.shrink();

            final progress = progressMap[fav.courseId] ?? 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CourseCard(
                imagePath: course.thumbnail,
                title: languageCode == 'ar' ? course.titleAr : course.titleEn,
                author: course.instructorName,
                courseId: course.id,
                rating: course.rating,
                description: languageCode == 'ar'
                    ? course.descriptionAr
                    : course.descriptionEn,
                progress: progress,
                isFavorite: true,
                onFavoriteToggle: () {
                  context.read<FavoritesCubit>().deleteFavorite(
                    userId: context.read<UserCubit>().userId!,
                    favoriteID: fav.id,
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
