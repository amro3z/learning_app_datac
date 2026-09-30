import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:training/ui/state/cubit/categories_cubit.dart';
import 'package:training/ui/state/cubit/courses_cubit.dart';
import 'package:training/ui/state/cubit/enrollments_cubit.dart';
import 'package:training/ui/state/cubit/favorites_cubit.dart';
import 'package:training/ui/state/cubit/recommended_cubit.dart';
import 'package:training/ui/state/cubit/popular_cubit.dart';
import 'package:training/ui/state/cubit/user_cubit.dart';
import 'package:training/ui/state/cubit/language_cubit.dart';
import 'package:training/ui/state/cubit/lessons_cubit.dart';
import 'package:training/utils/services/local_notifications.dart';
import 'package:training/ui/state/states/categories_state.dart';
import 'package:training/ui/state/states/courses_state.dart';
import 'package:training/ui/state/states/language_cubit_state.dart';
import 'package:training/ui/state/states/user_state.dart';

import 'package:training/ui/core/base.dart';
import 'package:training/ui/sections/enrollment_cources.dart';
import 'package:training/ui/sections/recommended_cources.dart';
import 'package:training/ui/screens/favorite_screen.dart';
import 'package:training/ui/screens/profile_page.dart';
import 'package:training/ui/widgets/categories_chips_section.dart';
import 'package:training/ui/widgets/course_card.dart';
import 'package:training/ui/widgets/floating_glass_bar.dart';
import 'package:training/ui/sections/not_enrolled_courses_section.dart';
import 'package:training/ui/widgets/searchbar.dart';
import 'package:training/utils/services/network_service.dart';
import 'package:training/ui/widgets/offline_overlay.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
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
    if (forceRefresh && !NetworkService.isConnected) return;

    if (forceRefresh) {
      await context.read<UserCubit>().refreshUser();
      if (!mounted) return;
    }

    final userId = context.read<UserCubit>().userId;
    if (userId == null || userId.isEmpty) return;

    final enrollmentCubit = context.read<EnrollmentsCubit>();
    final beforeState = enrollmentCubit.state;
    final before = beforeState is EnrollmentsLoaded
        ? {for (final e in beforeState.enrollments) e.courseId: e.status}
        : <int, String>{};

    await enrollmentCubit.getAllEnrollments(
      userId: userId,
      forceRefresh: true,
      silent: false,
    );
    if (!mounted) return;

    await Future.wait([
      context.read<CoursesCubit>().getAllCourses(forceRefresh: forceRefresh),
      context.read<LessonsCubit>().getLessons(forceRefresh: forceRefresh),
      context.read<FavoritesCubit>().getFavoritesList(userId: userId, forceRefresh: forceRefresh),
      context.read<RecommendedCubit>().getRecommendedList(forceRefresh: forceRefresh),
      context.read<PopularCubit>().getPopularList(forceRefresh: forceRefresh),
      context.read<CategoriesCubit>().getAllCategories(forceRefresh: forceRefresh),
    ]);

    final refreshedCoursesState = context.read<CoursesCubit>().state;
    final refreshedEnrollmentsState = enrollmentCubit.state;
    if (refreshedCoursesState is CoursesLoaded &&
        refreshedEnrollmentsState is EnrollmentsLoaded) {
      final statusByCourse = <int, String>{
        for (final enrollment in refreshedEnrollmentsState.enrollments)
          enrollment.courseId: enrollment.status,
      };
      debugPrint('========== REFRESH COURSE STATES ==========');
      for (final course in refreshedCoursesState.courses) {
        final enrollmentStatus = statusByCourse[course.id] ?? 'not_enrolled';
        debugPrint(
          'Course: ${course.titleEn} | ID: ${course.id} | Enrollment: $enrollmentStatus',
        );
      }
      debugPrint('===========================================');
    }

    if (before.isNotEmpty && mounted) {
      final afterState = enrollmentCubit.state;
      if (afterState is EnrollmentsLoaded) {
        for (final enrollment in afterState.enrollments) {
          final old = before[enrollment.courseId];
          if (old == 'pending' && enrollment.status == 'approved') {
            LocalNotifications.showNotification(
              navigator: false,
              title: 'Course request approved',
              body: 'Your instructor approved your request. The course is now available.',
            );
          } else if (old == 'pending' && enrollment.status == 'rejected') {
            LocalNotifications.showNotification(
              navigator: false,
              title: 'Course request rejected',
              body: 'Your instructor reviewed the request and did not approve it.',
            );
          }
        }
      }
    }
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
    final UserLoaded state = context.read<UserCubit>().state as UserLoaded;
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
        padding: EdgeInsets.only(left: 12, right: 12, top: 24, bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: kToolbarHeight),
            defaultText(
              context: context,
              text: isArabic
                  ? 'مرحبًا، ${state.Fname} 👋'
                  : 'Hello, ${state.Fname} 👋',
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
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state is CoursesError) {
                  return Padding(
                    padding: EdgeInsets.only(
                      top: getScreenHeight(context) * 0.05000,
                    ),
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
                  return SizedBox();
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

    final Map<int, String> enrollmentStatuses = enrollState is EnrollmentsLoaded
        ? {for (final e in enrollState.enrollments) e.courseId: e.status}
        : <int, String>{};

    return Column(
      children: courses.map((course) {
        final status = enrollmentStatuses[course.id];
        final bool isEnrolled = status == 'approved';

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: CourseCard(
            imagePath: course.thumbnail,
            title: isArabic ? course.titleAr : course.titleEn,
            author: course.instructorName,
            rating: course.rating,
            description: isArabic ? course.descriptionAr : course.descriptionEn,
            courseId: course.id,
            isFiltering: true,
            isEnrolled: isEnrolled,
            enrollmentStatus: status,
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
