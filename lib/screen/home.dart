import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubit/learn_cubit.dart';
import 'package:training/cubit/learn_state.dart';
import 'package:training/widgets/course_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LearnCubit>().getAllCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: BlocBuilder<LearnCubit, LearnState>(
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

            if (publishedCourses.isEmpty) {
              return const Center(child: Text('No published courses'));
            }

            final course = publishedCourses.first;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: CourseCard(
                imagePath: course.thumbnail,
                title: course.title,
                author: course.instructorName,
                rating: course.rating,
                progress: course.progress / 100,
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
