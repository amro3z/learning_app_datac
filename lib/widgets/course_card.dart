import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/enrollments_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/cubit/favorites_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/data/models/favorites.dart';
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
  final bool? isEnrolled;
  final double? height;

  const CourseCard({
    super.key,
    required this.title,
    required this.author,
    required this.rating,
    this.progress,
    required this.imagePath,
    this.isFavorite,
    required this.description,
    required this.courseId,
    this.isFiltering = false,
    this.isEnrolled = true,
    this.height,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  bool _isLoading = false;
  bool _notificationShown = false;

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

  void _showNoInternetNotification(bool isArabic) {
    LocalNotifications.showNotification(
      navigator: false,
      title: isArabic ? "مفيش نت" : "No Internet",
      body: isArabic
          ? "تأكد من اتصالك بالإنترنت"
          : "Please check your internet connection",
    );
  }

  void _openDetails(bool isArabic) {
    if (!NetworkService.isConnected) {
      _showNoInternetNotification(isArabic);
      return;
    }

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

  Future<void> _handleEnroll(bool isArabic) async {
    if (!NetworkService.isConnected) {
      _showNoInternetNotification(isArabic);
      return;
    }

    final userId = context.read<UserCubit>().userId;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      await context.read<EnrollmentsCubit>().enrollCourse(
        courseId: widget.courseId,
        userId: userId,
      );

      if (!_notificationShown) {
        _notificationShown = true;

        LocalNotifications.showNotification(
          navigator: true,
          title: isArabic ? "تم الاشتراك بنجاح" : "Enrollment Successful",
          body: isArabic
              ? "تم الاشتراك في ${widget.title}"
              : "You enrolled in ${widget.title}",
        );
      }

      if (!mounted) return;

      await context.read<EnrollmentsCubit>().getAllEnrollments(userId: userId);

      _openDetails(isArabic);
    } catch (e) {
      debugPrint("Enroll error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _defaultImage() {
    return Container(
      height: 140,
      width: double.infinity,
      color: Colors.grey.shade900,
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 40,
      ),
    );
  }

  void _toggleFavorite() {
    final favoritesCubit = context.read<FavoritesCubit>();
    final userId = context.read<UserCubit>().userId;

    if (userId == null) return;

    final state = favoritesCubit.state;

    if (state is FavoritesLoaded) {
      final fav = state.favoritesList
          .where((f) => f.courseId == widget.courseId)
          .cast<FavoritesModel?>()
          .firstOrNull;

      final isFavorite = fav != null;

      if (isFavorite) {
        favoritesCubit.deleteFavorite(favoriteID: fav!.id, userId: userId);
      } else {
        favoritesCubit.addToFavorites(
          courseId: widget.courseId,
          userId: userId,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final isArabic =
        langState is LanguageCubitLoaded && langState.languageCode == 'ar';

    return GestureDetector(
      onTap: widget.isEnrolled == true ? () => _openDetails(isArabic) : null,
      child: Container(
        height: widget.height ?? getScreenHeight(context) * 0.275,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: NetworkService.isConnected
                      ? Image.network(
                          widget.imagePath,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _defaultImage(),
                        )
                      : _defaultImage(),
                ),

                if (widget.isFiltering != true)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: BlocBuilder<FavoritesCubit, FavoritesState>(
                      builder: (context, state) {
                        bool isFavorite = false;

                        if (state is FavoritesLoaded) {
                          isFavorite = state.favoritesList.any(
                            (f) => f.courseId == widget.courseId,
                          );
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _toggleFavorite,
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.white,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  defaultText(
                    context: context,
                    text: widget.title,
                    size: getScreenWidth(context) * 0.04,
                    bold: true,
                    isCenter: false,
                  ),
                  const SizedBox(height: 4),
                  defaultText(
                    context: context,
                    text: widget.author,
                    size: getScreenWidth(context) * 0.033,
                    color: Colors.white70,
                    isCenter: false,
                  ),
                  const SizedBox(height: 8),
                  ratingWidget(value: widget.rating, context: context),
                  const SizedBox(height: 10),
                  if (widget.isEnrolled == false)
                    FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slide,
                        child: CustomGlowButton(
                          width: double.infinity,
                          textSize: getScreenWidth(context) * 0.035,
                          title: _isLoading
                              ? (isArabic ? "جاري الاشتراك..." : "Enrolling...")
                              : (isArabic ? "اشترك الآن" : "Enroll Now"),
                          onPressed: _isLoading
                              ? null
                              : () => _handleEnroll(isArabic),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
