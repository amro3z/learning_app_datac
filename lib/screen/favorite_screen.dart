import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/courses_cubit.dart';
import 'package:training/cubits/states/courses_state.dart';
import 'package:training/helper/base.dart';
import 'package:training/widgets/course_card.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CoursesCubit, LearnState>(
        builder: (context, state) {
          if (state is Loading || state is LearnInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is Error) {
            return Center(child: Text(state.message));
          }

          if (state is LearnLoaded) {
            final publishedCourses = state.courses
                .where((c) => c.status == 'published')
                .toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                top: 24,
                bottom: 90,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: kTextTabBarHeight),
                  defaultText(text: "My Favorites", size: 24),
                  SizedBox(height: 10),
                  defaultText(
                    text: "3 courses saved",
                    size: 12,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  ...List.generate(publishedCourses.length, (index) {
                    final course = publishedCourses[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CourseCard(
                        imagePath: course.thumbnail,
                        title: course.title,
                        author: course.instructorName,
                        rating: course.rating,
                        progress: course.progress / 100,
                      ),
                    );
                  }),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
