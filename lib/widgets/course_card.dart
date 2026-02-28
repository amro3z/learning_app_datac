import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/enrollments_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/helper/base.dart';
import 'package:training/helper/custom_glow_buttom.dart';
import 'package:training/services/local_notifications.dart';
import 'package:training/services/network_service.dart';


class CourseCard extends StatefulWidget {
  final String title;
  final String author;
  final double rating;
  final double? progress;
  final String imagePath;
  final bool? isFavorite;
  final String description;
  final int courseId;
  final bool? isFiltering;
  final VoidCallback? onFavoriteToggle;
  final bool? isEnrolled;
  final double height;

  const CourseCard({
    super.key,
    required this.title,
    required this.author,
    required this.rating,
    this.progress,
    required this.imagePath,
    this.isFavorite,
    this.onFavoriteToggle,
    required this.description,
    required this.courseId,
    this.isFiltering = false,
    this.isEnrolled = true,
    this.height = 270,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    if (widget.isEnrolled == false) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final isArabic =
        langState is LanguageCubitLoaded && langState.languageCode == 'ar';

    return GestureDetector(
      onTap: () {
        if (!NetworkService.isConnected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.black,
              showCloseIcon: true,
              content: Text(
                isArabic ? 'لا يوجد اتصال بالإنترنت' : 'No internet connection',
              ),
            ),
          );
          return;
        }

        if (widget.isEnrolled == true) {
          Navigator.pushNamed(
            context,
            '/course_details',
            arguments: {
              'imageURL': widget.imagePath,
              'title': widget.title,
              'instructor': widget.author,
              'description': widget.description,
              'courseId': widget.courseId,
            },
          );
        }
      },
      child: Container(
        height: widget.isFiltering == true && widget.isEnrolled == true
            ? 250
            : widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildImage(), _buildBody(isArabic)],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Image.network(
            widget.imagePath,
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        if (widget.isFiltering != true)
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              onPressed: widget.onFavoriteToggle,
              icon: Icon(
                widget.isFavorite == true
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: widget.isFavorite == true ? Colors.red : Colors.white,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(bool isArabic) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          defaultText(
            context: context,
            text: widget.title,
            size: 16,
            bold: true,
            isCenter: false,
          ),
          const SizedBox(height: 4),
          defaultText(
            context: context,
            text: widget.author,
            size: 13,
            color: Colors.white70,
            isCenter: false,
          ),
          const SizedBox(height: 8),
          ratingWidget(value: widget.rating, context: context),
          const SizedBox(height: 10),
          if (widget.isFiltering != true && widget.progress != null)
            progressBar(progress: widget.progress!),

          if (widget.isEnrolled == false)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: CustomGlowButton(
                    width: double.infinity,
                    textSize: 13,
                    title: isArabic ? "اشترك الآن" : "Enroll Now",
                    onPressed: () async {
                      if (!NetworkService.isConnected) {
                        LocalNotifications.showNotification(
                          navigator: false,
                          title: isArabic
                              ? 'مفيش نت'
                              : 'No internet connection',
                          body: isArabic
                              ? 'تأكد من اتصالك بالإنترنت وحاول مرة تانية'
                              : 'Please check your internet connection and try again',
                        );
                        return;
                      }

                      final userId = context.read<UserCubit>().userId!;

                      await context.read<EnrollmentsCubit>().enrollCourse(
                        courseId: widget.courseId,
                        userId: userId,
                      );

                      if (!mounted) return;

                      LocalNotifications.showNotification(
                        navigator: true,
                        title: isArabic
                            ? "تم الاشتراك بنجاح"
                            : "Enrollment Successful",
                        body: isArabic
                            ? "تم الاشتراك في ${widget.title}"
                            : "You enrolled in ${widget.title}",
                        arguments: {
                          'imageURL': widget.imagePath,
                          'title': widget.title,
                          'instructor': widget.author,
                          'description': widget.description,
                          'courseId': widget.courseId,
                        },
                      );

                      await context.read<EnrollmentsCubit>().getAllEnrollments(
                        userId: userId,
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}



