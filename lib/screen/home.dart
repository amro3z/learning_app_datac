import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/courses_cubit.dart';
import 'package:training/helper/base.dart';
import 'package:training/screen/favorite_screen.dart';
import 'package:training/screen/profile_page.dart';
import 'package:training/widgets/categories_chips_section.dart';
import 'package:training/widgets/course_card.dart';
import 'package:training/widgets/floating_glass_bar.dart';
import 'package:training/widgets/popular_card.dart';
import 'package:training/widgets/recommended_card.dart';
import 'package:training/widgets/searchbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  String? selectedCategory;

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
          IndexedStack(
            index: currentIndex,
            children: [_homePage(), FavoriteScreen(), ProfilePage()],
          ),
          FloatingGlassBar(
            currentIndex: currentIndex,
            onItemSelected: (index) {
              setState(() => currentIndex = index);
            },
          ),
        ],
      ),
    );
  }

  /// ===== Home Page =====
  Widget _homePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 24, bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: kToolbarHeight),

          defaultText(text: 'Hello, Learner 👋', size: 24, isCenter: false),
          const SizedBox(height: 6),
          defaultText(
            text: 'What would you like to learn today?',
            size: 14,
            color: Colors.white70,
            isCenter: false,
          ),

          const SizedBox(height: 20),
          CoursesSearchBar(),

          const SizedBox(height: 20),
          defaultText(text: 'Categories', size: 18, isCenter: false),
          const SizedBox(height: 12),
          CategoriesChipsSection(),

          const SizedBox(height: 28),
          defaultText(text: 'Continue Learning', size: 18, isCenter: false),
          const SizedBox(height: 12),
          EnrollmentCourse(),
          const SizedBox(height: 24),
          defaultText(text: "Recommended Courses", size: 18),
          const SizedBox(height: 12),
          RecommendedCourses(),
          const SizedBox(height: 12),
          defaultText(text: "Popular This Week", size: 18),
          PopularCourses(),
        ],
      ),
    );
  }
}
