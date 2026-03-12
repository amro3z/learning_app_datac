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
import 'package:training/logic/enrollment_cources.dart';
import 'package:training/logic/recommended_cources.dart';
import 'package:training/screen/favorite_screen.dart';
import 'package:training/screen/profile_page.dart';
import 'package:training/widgets/categories_chips_section.dart';
import 'package:training/widgets/course_card.dart';
import 'package:training/widgets/floating_glass_bar.dart';
import 'package:training/logic/not_enrolled_courses_section.dart';
import 'package:training/widgets/searchbar.dart';
import 'package:training/services/network_service.dart';
import 'package:training/widgets/offline_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  bool _showOfflineOverlay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadHomeData();
    });
  }

  Future<void> _loadHomeData({bool forceRefresh = false}) async {
    if (!mounted) return;

    final userId = context.read<UserCubit>().userId;
    if (userId == null) return;

    final online = NetworkService.isConnected;
    if (forceRefresh && !online) return;

    final refresh = forceRefresh;

    await Future.wait([
      context.read<CoursesCubit>().getAllCourses(forceRefresh: refresh),
      context.read<EnrollmentsCubit>().getAllEnrollments(
        userId: userId,
        forceRefresh: refresh,
      ),
      context.read<FavoritesCubit>().getFavoritesList(
        userId: userId,
        forceRefresh: refresh,
      ),
      context.read<RecommendedCubit>().getRecommendedList(
        forceRefresh: refresh,
      ),
      context.read<PopularCubit>().getPopularList(forceRefresh: refresh),
      context.read<CategoriesCubit>().getAllCategories(forceRefresh: refresh),
    ]);
  }

  void _handleNoInternet() {
    setState(() => _showOfflineOverlay = true);
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

          if (_showOfflineOverlay)
            OfflineOverlay(
              onRetry: () {
                setState(() => _showOfflineOverlay = false);
              },
            ),
        ],
      ),
    );
  }

  Widget _homePage(bool isArabic) {
    return RefreshIndicator(
      onRefresh: () async {
        if (!NetworkService.isConnected) {
          _handleNoInternet();
          return;
        }
        await _loadHomeData(forceRefresh: true);
      },
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
            defaultText(
              context: context,
              text: isArabic ? 'مرحبًا، متعلم 👋' : 'Hello, Learner 👋',
              size: getScreenWidth(context) * 0.06,
              isCenter: false,
            ),
            SizedBox(height: getScreenHeight(context) * 0.01),
            defaultText(
              context: context,
              text: isArabic
                  ? 'ماذا تحب أن تتعلم اليوم؟'
                  : 'What would you like to learn today?',
              size: getScreenWidth(context) * 0.035,
              color: Colors.white70,
              isCenter: false,
            ),
            SizedBox(height: getScreenHeight(context) * 0.022),
            const CoursesSearchBar(),
            SizedBox(height: getScreenHeight(context) * 0.022),
            BlocBuilder<CoursesCubit, LearnState>(
              builder: (context, state) {
                final coursesCubit = context.watch<CoursesCubit>();
                final categoriesState = context.watch<CategoriesCubit>().state;

                final isCategorySelected =
                    categoriesState is CategoriesLoaded &&
                    categoriesState.selectedCategoryId != null;

                if (state is CoursesLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state is CoursesError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: defaultText(
                        context: context,
                        text: state.message,
                        size: getScreenWidth(context) * 0.04,
                        color: Colors.redAccent,
                      ),
                    ),
                  );
                }

                if (state is! CoursesLoaded) {
                  return const SizedBox();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    defaultText(
                      context: context,
                      text: isArabic ? 'التصنيفات' : 'Categories',
                      size: getScreenWidth(context) * 0.045,
                      isCenter: false,
                    ),
                    SizedBox(height: getScreenHeight(context) * 0.015),
                    const CategoriesChipsSection(),
                    SizedBox(height: getScreenHeight(context) * 0.025),
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
    final enrollState = context.watch<EnrollmentsCubit>().state;

    final Set<int> enrolledIds = enrollState is EnrollmentsLoaded
        ? enrollState.enrollments.map((e) => e.courseId).toSet()
        : <int>{};

    return Column(
      children: courses.map((course) {
        final bool isEnrolled = enrolledIds.contains(course.id);

        final double cardHeight = isEnrolled
            ? getScreenHeight(context) * 0.28
            : getScreenHeight(context) * 0.33;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: CourseCard(
            height: cardHeight,
            imagePath: course.thumbnail,
            title: isArabic ? course.titleAr : course.titleEn,
            author: course.instructorName,
            rating: course.rating,
            description: isArabic ? course.descriptionAr : course.descriptionEn,
            courseId: course.id,
            isFiltering: true,
            isEnrolled: isEnrolled,
          ),
        );
      }).toList(),
    );
  }

  Widget _defaultHomeSections(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EnrollmentCourse(),
        SizedBox(height: getScreenHeight(context) * 0.025),
        const NotEnrolledCoursesSection(),
        defaultText(
          context: context,
          text: isArabic ? 'الدورات المقترحة' : 'Recommended Courses',
          size: getScreenWidth(context) * 0.045,
          isCenter: false,
        ),
        SizedBox(height: getScreenHeight(context) * 0.015),
        const RecommendedCourses(),
        SizedBox(height: getScreenHeight(context) * 0.024),
      ],
    );
  }
}
