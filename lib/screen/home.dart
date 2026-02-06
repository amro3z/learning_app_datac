import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/courses_cubit.dart';
import 'package:training/cubits/states/courses_state.dart';
import 'package:training/helper/base.dart';
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

  final List<Map<String, dynamic>> categories = [
    {'title': 'Development', 'icon': Icons.code, 'color': Color(0xFF3BA9FF)},
    {
      'title': 'Design',
      'icon': Icons.palette_outlined,
      'color': Color(0xFFB37CFF),
    },
    {
      'title': 'Business',
      'icon': Icons.card_travel,
      'color': Color(0xFFFF9F43),
    },
    {
      'title': 'AI',
      'icon': Icons.smart_toy_outlined,
      'color': Color(0xFF2ED573),
    },
    {
      'title': 'Marketing',
      'icon': Icons.campaign_outlined,
      'color': Color(0xFFFF6B81),
    },
    {'title': 'Languages', 'icon': Icons.language, 'color': Color(0xFF1DD1A1)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
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

          return SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              top: 24,
              bottom: 90,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                defaultText(
                  text: 'Hello, Learner 👋',
                  size: 24,
                  isCenter: false,
                ),
                const SizedBox(height: 6),
                defaultText(
                  text: 'What would you like to learn today?',
                  size: 14,
                  bold: false,
                  isCenter: false,
                  color: Colors.white70,
                ),

                const SizedBox(height: 20),

                CoursesSearchBar(),

                const SizedBox(height: 20),
                defaultText(text: 'Categories', size: 18, isCenter: false),
                const SizedBox(height: 12),
                CategoriesChipsSection(),

                const SizedBox(height: 28),
                defaultText(
                  text: 'Continue Learning',
                  size: 18,
                  isCenter: false,
                ),
                const SizedBox(height: 12),
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
                defaultText(text: "Recommended Courses", size: 18),
                const SizedBox(height: 12),
                RecommendedCard(),
                const SizedBox(height: 12),
                defaultText(text: "Popular This Week", size: 18),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 2,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,

                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, index) {
                    return PopularCard();
                  },
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
