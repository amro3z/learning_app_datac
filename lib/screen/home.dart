import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/courses_cubit.dart';
import 'package:training/cubits/states/courses_state.dart';
import 'package:training/helper/base.dart';
import 'package:training/screen/profile_page.dart';
import 'package:training/widgets/course_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<CoursesCubit>().getAllCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// ===== Pages =====
          IndexedStack(
            index: _currentIndex,
            children: [
              _homePage(),
              const Center(
                child: Text(
                  'Favorites Page',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ProfilePage(),
            ],
          ),

          /// ===== Floating Glass Bottom Bar =====
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _navItem(Icons.home, 'Home', 0),
                      _navItem(Icons.favorite_border, 'Favorites', 1),
                      _navItem(Icons.person_outline, 'Profile', 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ===== Home Page =====
  Widget _homePage() {
    return BlocBuilder<CoursesCubit, LearnState>(
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

          return ListView.builder(
            padding: const EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: 120,
            ),
            itemCount: publishedCourses.length,
            itemBuilder: (context, index) {
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
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// ===== Bottom Bar Item =====
  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4FACFE), Color(0xFF9B5CFF)],
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6A5CFF).withOpacity(0.6),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey),
            const SizedBox(height: 4),
            defaultText(
              text: label,
              size: 12,
              isCenter: false,
              color: isSelected ? Colors.white : Colors.grey,
              bold: false,
            ),
          ],
        ),
      ),
    );
  }
}
