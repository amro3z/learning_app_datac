import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/enrollments_cubit.dart';
import 'package:training/cubits/cubit/favorites_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/data/models/favorites.dart';
import 'package:training/helper/base.dart';

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
    return GestureDetector(
      onTap: () {
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
                    imagePath,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                isFiltering == true
                    ? const SizedBox.shrink()
                    : Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: onFavoriteToggle,
                            icon:isFiltering == true ? const SizedBox.shrink() : Icon(
                              isFavorite!
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite! ? Colors.red : Colors.white,
                              size: 20,
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
                    text: title,
                    size: 16,
                    bold: true,
                    isCenter: false,
                  ),
                  const SizedBox(height: 4),
                  defaultText(
                    text: author,
                    size: 13,
                    color: Colors.white70,
                    isCenter: false,
                  ),
                  const SizedBox(height: 8),
                  ratingWidget(value: rating),
                  const SizedBox(height: 10),
                  isFiltering == true
                      ? const SizedBox.shrink()
                      : progressBar(progress: progress!),
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

          final favoritesState = context.watch<FavoritesCubit>().state;
          final favorites = favoritesState is FavoritesLoaded
              ? favoritesState.favoritesList
              : [];
          final courseMap = {for (var c in courses) c.id: c};

          final Map<int, dynamic> uniqueEnrollments = {
            for (var e in enrollments) e.courseId: e,
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
                  title: course.title,
                  author: course.instructorName,
                  rating: course.rating,
                  progress: e.progressPercent,
                  description: course.description,
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
          return const Center(
            child: Text(
              'No favorites yet',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        /// ===== MAP COURSES =====
        final Map<int, CoursesModel> courseMap = {
          for (var c in loaded.courses) c.id: c,
        };

        /// ===== REMOVE DUPLICATES (courseId unique) =====
        final Map<int, FavoritesModel> uniqueFavorites = {
          for (var fav in loaded.favoritesList) fav.courseId: fav,
        };

        /// ===== GET ENROLLMENTS PROGRESS =====
        final enrollmentsState = context.watch<EnrollmentsCubit>().state;

        final Map<int, double> progressMap =
            enrollmentsState is EnrollmentsLoaded
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
                title: course.title,
                author: course.instructorName,
                courseId: course.id,
                rating: course.rating,
                description: course.description,
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
