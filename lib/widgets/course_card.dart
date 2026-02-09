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
  final double progress;
  final String imagePath;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const CourseCard({
    super.key,
    required this.title,
    required this.author,
    required this.rating,
    required this.progress,
    required this.imagePath,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/course_details');
      },
      child: Container(
        height: 265,
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
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
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
                  progressBar(progress: progress),
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
        if (state is! EnrollmentsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final enrollments = state.enrollments;
        final courses = state.courses;

        final favoritesState = context.watch<FavoritesCubit>().state;
        final favorites = favoritesState is FavoritesLoaded
            ? favoritesState.favoritesList
            : [];

        /// ===== MAP COURSES =====
        final courseMap = {for (var c in courses) c.id: c};

        /// ===== DEDUP ENROLLMENTS BY COURSE ID =====
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
                progress: course.progress / 100,
                isFavorite: isFavorite,
                onFavoriteToggle: () {
                  final cubit = context.read<FavoritesCubit>();

                  if (isFavorite) {
                    cubit.deleteFavorite(favoriteID: fav.id);
                  } else {
                    cubit.addToFavorites(courseId: course.id, userId: userId);
                  }
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}





class FavoriteCourses extends StatelessWidget {
  const FavoriteCourses({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        if (state is FavoritesLoading || state is FavoritesInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is FavoritesError) {
          return Center(child: Text(state.message));
        }

        final loaded = state as FavoritesLoaded;

        if (loaded.favoritesList.isEmpty) {
          return const Center(child: Text('No favorites yet'));
        }

        /// ===== MAP COURSES =====
        final Map<int, CoursesModel> courseMap = {
          for (var c in loaded.courses) c.id: c,
        };

        /// ===== REMOVE DUPLICATES BY courseId =====
        final Map<int, FavoritesModel> uniqueFavorites = {
          for (var fav in loaded.favoritesList)
            fav.courseId: fav, // لو اتكرر نفس courseId هيتكتب مرة واحدة
        };

        return Column(
          children: uniqueFavorites.values.map((fav) {
            final course = courseMap[fav.courseId];
            if (course == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CourseCard(
                imagePath: course.thumbnail,
                title: course.title,
                author: course.instructorName,
                rating: course.rating,
                progress: course.progress / 100,
                isFavorite: true,
                onFavoriteToggle: () {
                  context.read<FavoritesCubit>().deleteFavorite(
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
