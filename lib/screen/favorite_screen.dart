import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/favorites_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/helper/base.dart';
import 'package:training/logic/favorites_cources.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();

    final userId = context.read<UserCubit>().userId;

    if (userId != null) {
      context.read<FavoritesCubit>().getFavoritesList(userId: userId);
    }
  }

  Future<void> _onRefresh() async {
    final userId = context.read<UserCubit>().userId;

    if (userId != null) {
      await context.read<FavoritesCubit>().getFavoritesList(userId: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;

    final isArabic =
        langState is LanguageCubitLoaded && langState.languageCode == 'ar';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              top: 24,
              bottom: 90,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: kTextTabBarHeight),

                defaultText(
                  context: context,
                  text: isArabic ? "المفضلة" : "My Favorites",
                  size: getScreenWidth(context) * 0.053,
                  isCenter: false,
                ),

                SizedBox(height: getScreenHeight(context) * 0.015),

                BlocBuilder<FavoritesCubit, FavoritesState>(
                  builder: (context, state) {
                    if (state is FavoritesLoading ||
                        state is FavoritesInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is FavoritesError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final loaded = state as FavoritesLoaded;

                    final availableCourseIds = loaded.courses
                        .map((course) => course.id)
                        .toSet();

                    final uniqueCourseIds = loaded.favoritesList
                        .map((fav) => fav.courseId)
                        .where(
                          (courseId) => availableCourseIds.contains(courseId),
                        )
                        .toSet()
                        .toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // COUNT
                        defaultText(
                          context: context,
                          text: isArabic
                              ? "${uniqueCourseIds.length} دورة محفوظة"
                              : "${uniqueCourseIds.length} courses saved",
                          size: getScreenWidth(context) * 0.035,
                          color: Colors.grey,
                        ),

                        SizedBox(height: getScreenHeight(context) * 0.022),

                        FavoriteCourses(
                          courses: loaded.courses,
                          uniqueCourseIds: uniqueCourseIds,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
