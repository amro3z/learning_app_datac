// lib/widgets/recommended_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/enrollments_cubit.dart';
import 'package:training/cubits/cubit/recommended_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/helper/base.dart';
import 'package:training/services/local_notifications.dart';
import 'package:training/services/network_service.dart';

class RecommendedCard extends StatefulWidget {
  const RecommendedCard({
    super.key,
    required this.courseId,
    required this.titleEn,
    required this.titleAr,
    required this.author,
    required this.rating,
    required this.imagePath,
    required this.isEnrolled,
    required this.descriptionAr,
    required this.descriptionEn,
  });

  final int courseId;
  final String titleEn;
  final String titleAr;
  final String author;
  final double rating;
  final String imagePath;
  final bool isEnrolled;
  final String descriptionAr;
  final String descriptionEn;
  @override
  State<RecommendedCard> createState() => _RecommendedCardState();
}

class _RecommendedCardState extends State<RecommendedCard> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final languageCode = langState is LanguageCubitLoaded
        ? langState.languageCode
        : 'en';

    final title = languageCode == 'ar' ? widget.titleAr : widget.titleEn;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _NetworkOrPlaceholderImage(
              imageUrl: widget.imagePath,
              height: 110,
              width: 110,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                defaultText(
                  context: context,
                  text: title,
                  size: 14,
                  color: Colors.white,
                  bold: true,
                  isCenter: false,
                ),
                const SizedBox(height: 4),
                defaultText(
                  context: context,
                  text: widget.author,
                  size: 12,
                  color: Colors.white.withOpacity(0.6),
                  isCenter: false,
                ),
                const SizedBox(height: 8),
                defaultText(
                  text: "⭐ ${widget.rating}",
                  size: 12,
                  context: context,
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildButton(
                    context,
                    languageCode,
                    widget.titleAr,
                    widget.titleEn,
                    widget.descriptionAr,
                    widget.descriptionEn,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String languageCode,
    String titleAR,
    String titleEN,
    String descriptionAr,
    String descriptionEn,
  ) {
    final title = languageCode == 'ar' ? titleAR : titleEN;
    final description = languageCode == 'ar' ? descriptionAr : descriptionEn;
    if (widget.isEnrolled) return _successButton(languageCode);
    if (_loading) return _loadingButton();
    return _enrollButton(context, languageCode, title, description);
  }

  Widget _enrollButton(
    BuildContext context,
    String languageCode,
    String title,
    String description,
  ) {
    return SizedBox(
      width: 100,
      height: 32,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: _loading
            ? null
            : () async {
                if (!NetworkService.isConnected) {
                  LocalNotifications.showNotification(
                    navigator: false,
                    title: languageCode == 'ar'
                        ? 'مفيش نت'
                        : 'No internet connection',
                    body: languageCode == 'ar'
                        ? 'تأكد من اتصالك بالإنترنت وحاول مرة تانية'
                        : 'Please check your internet connection and try again',
                  );
                  return;
                }

                if (widget.isEnrolled) return;

                setState(() => _loading = true);

                await context.read<EnrollmentsCubit>().enrollCourse(
                  courseId: widget.courseId,
                  userId: context.read<UserCubit>().userId!,
                );
                LocalNotifications.showNotification(
                  navigator: true,
                  title: 'Enrollment Successful',
                  body: 'You enrolled in $title',
                  arguments: {
                    'imageURL': widget.imagePath,
                    'title': title,
                    'instructor': widget.author,
                    'description': description,
                    'courseId': widget.courseId,
                  },
                );
                await context.read<EnrollmentsCubit>().getAllEnrollments(
                  userId: context.read<UserCubit>().userId!,
                );

                if (mounted) setState(() => _loading = false);
              },
        child: Text(
          languageCode == 'ar' ? 'اشترك' : 'Enroll',
          style: TextStyle(
            fontSize: 12,
            fontFamily: languageCode == 'ar'
                ? 'CustomArabicFont'
                : 'CustomEnglishFont',
          ),
        ),
      ),
    );
  }

  Widget _loadingButton() {
    return const SizedBox(
      width: 100,
      height: 32,
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _successButton(String languageCode) {
    return Container(
      width: 100,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: languageCode == 'ar'
            ? const Text(
                'مشترك',
                style: TextStyle(color: Colors.white, fontSize: 12),
              )
            : const Icon(Icons.check, color: Colors.white, size: 18),
      ),
    );
  }
}

class RecommendedCourses extends StatelessWidget {
  const RecommendedCourses({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageCubitState>(
      builder: (context, langState) {
        final languageCode = langState is LanguageCubitLoaded
            ? langState.languageCode
            : 'en';

        return BlocBuilder<RecommendedCubit, RecommendedState>(
          builder: (context, state) {
            if (state is RecommendedLoading || state is RecommendedInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RecommendedError) {
              return Center(child: Text(state.message));
            }

            if (state is RecommendedLoaded) {
              final recommends = state.recommends;
              final courses = state.courses;

              final enrollmentsState = context.watch<EnrollmentsCubit>().state;

              final Set<int> enrolledCourseIds =
                  enrollmentsState is EnrollmentsLoaded
                  ? enrollmentsState.enrollments.map((e) => e.courseId).toSet()
                  : <int>{};

              final Map<int, CoursesModel> courseMap = {
                for (var course in courses) course.id: course,
              };

              final List<CoursesModel> recommendedCourses = recommends
                  .map((r) => courseMap[r.recommendCourse])
                  .whereType<CoursesModel>()
                  .toList();

              if (recommendedCourses.isEmpty) {
                return Center(
                  child: Text(
                    languageCode == 'ar'
                        ? 'لا توجد كورسات مقترحة'
                        : 'No recommended courses',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: languageCode == 'ar'
                          ? 'CustomArabicFont'
                          : 'CustomEnglishFont',
                    ),
                  ),
                );
              }

              return Column(
                children: recommendedCourses.map((course) {
                  final bool isEnrolled = enrolledCourseIds.contains(course.id);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: RecommendedCard(
                      descriptionAr: course.descriptionAr,
                      descriptionEn: course.descriptionEn,
                      courseId: course.id,
                      imagePath: course.thumbnail,
                      titleEn: course.titleEn,
                      titleAr: course.titleAr,
                      author: course.instructorName,
                      rating: course.rating,
                      isEnrolled: isEnrolled,
                    ),
                  );
                }).toList(),
              );
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}

class _NetworkOrPlaceholderImage extends StatelessWidget {
  const _NetworkOrPlaceholderImage({
    required this.imageUrl,
    required this.height,
    required this.width,
    this.borderRadius,
  });

  final String imageUrl;
  final double height;
  final double width;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final online = NetworkService.isConnected;

    Widget placeholder() {
      return Container(
        height: height,
        width: width,
        color: Colors.white10,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.white54,
          ),
        ),
      );
    }

    if (!online) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: placeholder(),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: height,
            width: width,
            color: Colors.white10,
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      ),
    );
  }
}
