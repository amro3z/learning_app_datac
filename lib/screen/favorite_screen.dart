import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/favorites_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/helper/base.dart';
import 'package:training/widgets/course_card.dart';

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
                SizedBox(height: kTextTabBarHeight),

                /// TITLE
                defaultText(
                  context: context,
                  text: isArabic ? "المفضلة" : "My Favorites",
                  size: 24,
                  isCenter: false,
                ),

                const SizedBox(height: 10),

                /// COUNT
                BlocBuilder<FavoritesCubit, FavoritesState>(
                  builder: (context, state) {
                    if (state is FavoritesLoaded) {
                      return defaultText(
                        context: context,
                        text: isArabic
                            ? "${state.favoritesList.length} دورة محفوظة"
                            : "${state.favoritesList.length} courses saved",
                        size: 12,
                        color: Colors.grey,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 20),

                /// COURSES LIST
                const FavoriteCourses(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
