// lib/widgets/course_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

import 'package:training/cubits/cubit/enrollments_cubit.dart';
import 'package:training/cubits/cubit/favorites_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/data/models/favorites.dart';
import 'package:training/helper/base.dart';
import 'package:training/services/network_service.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String author;
  final double rating;
  final double? progress;
  final String imagePath;
  final bool? isFavorite;
  final String description;
  final int courseId;
  final bool? isFiltering;
  final VoidCallback? onFavoriteToggle;

  const CourseCard({
    super.key,
    required this.title,
    required this.author,
    required this.rating,
    this.progress,
    required this.imagePath,
    this.isFavorite,
    this.onFavoriteToggle,
    required this.description,
    required this.courseId,
    this.isFiltering = false,
  });

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final isArabic =
        langState is LanguageCubitLoaded && langState.languageCode == 'ar';

    return GestureDetector(
      onTap: () {
        if (!NetworkService.isConnected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.black,
              showCloseIcon: true,
              content: Text(
                isArabic ? 'لا يوجد اتصال بالإنترنت' : 'No internet connection',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: isArabic
                      ? 'CustomArabicFont'
                      : 'CustomEnglishFont',
                ),
              ),
            ),
          );
          return;
        }

        Navigator.pushNamed(
          context,
          '/course_details',
          arguments: {
            'imageURL': imagePath,
            'title': title,
            'instructor': author,
            'description': description,
            'courseId': courseId,
          },
        );
      },
      child: Container(
        height: isFiltering == true ? 245 : 265,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
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
                    imagePath,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 140,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                    errorBuilder: (context, error, stack) {
                      return Container(
                        height: 140,
                        width: double.infinity,
                        color: Colors.white10,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.white54,
                        ),
                      );
                    },
                  ),
                ),
                if (isFiltering != true)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      onPressed: onFavoriteToggle,
                      icon: Icon(
                        isFavorite == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: isFavorite == true ? Colors.red : Colors.white,
                        size: 20,
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
                    context: context,
                    text: title,
                    size: 16,
                    bold: true,
                    isCenter: false,
                  ),
                  const SizedBox(height: 4),
                  defaultText(
                    context: context,
                    text: author,
                    size: 13,
                    color: Colors.white70,
                    isCenter: false,
                  ),
                  const SizedBox(height: 8),
                  ratingWidget(value: rating, context: context),
                  const SizedBox(height: 10),
                  if (isFiltering != true && progress != null)
                    progressBar(progress: progress!),
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
    final userId = context.read<UserCubit>().userId!;
    final langState = context.watch<LanguageCubit>().state;
    final languageCode = langState is LanguageCubitLoaded
        ? langState.languageCode
        : 'en';

    return BlocBuilder<EnrollmentsCubit, EnrollmentsState>(
      builder: (context, state) {
        if (state is EnrollmentsLoading || state is EnrollmentsInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is EnrollmentsError) {
          return Center(child: Text(state.message));
        }

        if (state is EnrollmentsLoaded) {
          final favoritesState = context.watch<FavoritesCubit>().state;

          final favorites = favoritesState is FavoritesLoaded
              ? favoritesState.favoritesList
              : [];

          final courseMap = {for (var c in state.courses) c.id: c};

          final uniqueEnrollments = {
            for (var e in state.enrollments) e.courseId: e,
          };

          return Column(
            children: uniqueEnrollments.values.map((e) {
              final course = courseMap[e.courseId]!;
              final fav = favorites
                  .where((f) => f.courseId == course.id)
                  .cast<FavoritesModel?>()
                  .firstOrNull;

              final isFavorite = fav != null;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CourseCard(
                  imagePath: course.thumbnail,
                  title: languageCode == 'ar' ? course.titleAr : course.titleEn,
                  author: course.instructorName,
                  rating: course.rating,
                  progress: e.progressPercent / 100,
                  description: languageCode == 'ar'
                      ? course.descriptionAr
                      : course.descriptionEn,
                  isFavorite: isFavorite,
                  courseId: course.id,
                  onFavoriteToggle: () {
                    final cubit = context.read<FavoritesCubit>();

                    if (isFavorite) {
                      cubit.deleteFavorite(favoriteID: fav.id, userId: userId);
                    } else {
                      cubit.addToFavorites(courseId: course.id, userId: userId);
                    }
                  },
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
