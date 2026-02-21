import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/categories_cubit.dart';
import 'package:training/cubits/cubit/courses_cubit.dart';
import 'package:training/cubits/cubit/enrollments_cubit.dart';
import 'package:training/cubits/cubit/favorites_cubit.dart';
import 'package:training/cubits/cubit/recommended_cubit.dart';
import 'package:training/cubits/cubit/popular_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/categories_state.dart';
import 'package:training/cubits/states/courses_state.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/helper/base.dart';
import 'package:training/screen/favorite_screen.dart';
import 'package:training/screen/profile_page.dart';
import 'package:training/widgets/categories_chips_section.dart';
import 'package:training/widgets/course_card.dart';
import 'package:training/widgets/floating_glass_bar.dart';
import 'package:training/widgets/recommended_card.dart';
import 'package:training/widgets/popular_card.dart';
import 'package:training/widgets/searchbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHomeData();
    });
  }

  Future<void> _loadHomeData() async {
    final userId = context.read<UserCubit>().userId;
    if (userId == null) return;

    await Future.wait([
      context.read<CoursesCubit>().getAllCourses(),
      context.read<EnrollmentsCubit>().getAllEnrollments(userId: userId),
      context.read<FavoritesCubit>().getFavoritesList(userId: userId),
      context.read<RecommendedCubit>().getRecommendedList(),
      context.read<PopularCubit>().getPopularList(),
      context.read<CategoriesCubit>().getAllCategories(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final isArabic =
        langState is LanguageCubitLoaded && langState.languageCode == 'ar';

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: [
              _homePage(isArabic),
              const FavoriteScreen(),
              const ProfilePage(),
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

  Widget _homePage(bool isArabic) {
    return RefreshIndicator(
      onRefresh: _loadHomeData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
          top: 24,
          bottom: 90,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: kToolbarHeight),

            /// HEADER
            defaultText(
              context: context,
              text: isArabic ? 'مرحبًا، متعلم 👋' : 'Hello, Learner 👋',
              size: 24,
              isCenter: false,
            ),
            const SizedBox(height: 6),
            defaultText(
              context: context,
              text: isArabic
                  ? 'ماذا تحب أن تتعلم اليوم؟'
                  : 'What would you like to learn today?',
              size: 14,
              color: Colors.white70,
              isCenter: false,
            ),

            const SizedBox(height: 20),
            const CoursesSearchBar(),
            const SizedBox(height: 20),

            BlocBuilder<CoursesCubit, LearnState>(
              builder: (context, state) {
                final coursesCubit = context.read<CoursesCubit>();
                final categoriesState = context.watch<CategoriesCubit>().state;

                final isCategorySelected =
                    categoriesState is CategoriesLoaded &&
                    categoriesState.selectedCategoryId != null;

                if (state is! CoursesLoaded) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    defaultText(
                      context: context,
                      text: isArabic ? 'التصنيفات' : 'Categories',
                      size: 18,
                      isCenter: false,
                    ),
                    const SizedBox(height: 12),
                    const CategoriesChipsSection(),
                    const SizedBox(height: 24),

                    if (coursesCubit.isFiltering || isCategorySelected)
                      _filteredCoursesSection(state.filteredCourses, isArabic)
                    else
                      _defaultHomeSections(isArabic),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _filteredCoursesSection(List courses, bool isArabic) {
    if (courses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: defaultText(
            context: context,
            text: isArabic ? "لا توجد دورات" : "No courses found",
            size: 20,
            color: Colors.white70,
          ),
        ),
      );
    }

    return Column(
      children: courses.map((course) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CourseCard(
            imagePath: course.thumbnail,
            title: isArabic ? course.titleAr : course.titleEn,
            author: course.instructorName,
            rating: course.rating,
            description: isArabic ? course.descriptionAr : course.descriptionEn,
            isFiltering: true,
            courseId: course.id,
          ),
        );
      }).toList(),
    );
  }

  Widget _defaultHomeSections(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        defaultText(
          context: context,
          text: isArabic ? 'استكمل التعلم' : 'Continue Learning',
          size: 18,
          isCenter: false,
        ),
        const SizedBox(height: 12),
        const EnrollmentCourse(),

        const SizedBox(height: 24),

        defaultText(
          context: context,
          text: isArabic ? 'الدورات المقترحة' : 'Recommended Courses',
          size: 18,
          isCenter: false,
        ),
        const SizedBox(height: 12),
        const RecommendedCourses(),

        const SizedBox(height: 24),

        defaultText(
          context: context,
          text: isArabic ? 'الأكثر شعبية هذا الأسبوع' : 'Popular This Week',
          size: 18,
          isCenter: false,
        ),
        const SizedBox(height: 12),
        const PopularCourses(),
      ],
    );
  }
}
