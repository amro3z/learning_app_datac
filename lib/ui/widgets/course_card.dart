import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/ui/state/cubit/enrollments_cubit.dart';
import 'package:training/ui/state/cubit/user_cubit.dart';
import 'package:training/ui/state/cubit/language_cubit.dart';
import 'package:training/ui/state/cubit/favorites_cubit.dart';
import 'package:training/ui/state/states/language_cubit_state.dart';
import 'package:training/data/models/favorites.dart';
import 'package:training/ui/core/base.dart';
import 'package:training/ui/core/app_colors.dart';
import 'package:training/ui/core/custom_glow_buttom.dart';
import 'package:training/utils/services/local_notifications.dart';
import 'package:training/utils/services/network_service.dart';

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
  final bool isEnrolled;
  final double? height;
  final String? enrollmentStatus;

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
    this.enrollmentStatus,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard>
    with SingleTickerProviderStateMixin {
  static final Set<int> _runningEnrollRequests = <int>{};

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  bool _isLoading = false;
  bool _notificationShown = false;

  bool get _canPressEnroll {
    if (widget.enrollmentStatus == 'pending' ||
        widget.enrollmentStatus == 'approved' ||
        widget.enrollmentStatus == 'rejected') {
      return false;
    }
    return !_isLoading && !_runningEnrollRequests.contains(widget.courseId);
  }

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
    if (!_canPressEnroll) return;

    if (!NetworkService.isConnected) {
      _showNoInternetNotification(isArabic);
      return;
    }

    final userCubit = context.read<UserCubit>();
    final enrollCubit = context.read<EnrollmentsCubit>();

    final userId = userCubit.userId;
    if (userId == null) return;

    _runningEnrollRequests.add(widget.courseId);
    if (mounted) setState(() => _isLoading = true);

    try {
      await enrollCubit.enrollCourse(
        courseId: widget.courseId,
        userId: userId,
      );

      if (!mounted) return;
      LocalNotifications.showNotification(
        navigator: false,
        title: isArabic ? "تم إرسال طلبك" : "Request sent",
        body: isArabic
            ? "المدرس هيراجع طلبك وهيوصلك إشعار أول ما يتم قبوله أو رفضه."
            : "The instructor will review your request. You'll be notified when it is approved or rejected.",
      );
    } catch (e) {
      debugPrint("Enroll error: $e");
    } finally {
      _runningEnrollRequests.remove(widget.courseId);

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _defaultImage() {
    return Container(
      height: getScreenHeight(context) * 0.17500,
      width: double.infinity,
      color: Colors.grey.shade900,
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: getScreenWidth(context) * 0.10256,
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
        favoritesCubit.deleteFavorite(favoriteID: fav.id, userId: userId);
      } else {
        favoritesCubit.addToFavorites(
          courseId: widget.courseId,
          userId: userId,
        );
      }
    }
  }

  String _enrollButtonTitle(bool isArabic) {
    if (_isLoading) {
      return isArabic ? "جاري الاشتراك..." : "Enrolling...";
    }

    if (widget.enrollmentStatus == 'pending' ||
        _runningEnrollRequests.contains(widget.courseId)) {
      return isArabic ? "قيد المراجعة" : "Pending review";
    }
    if (widget.enrollmentStatus == 'rejected') {
      return isArabic ? "تم رفض الطلب" : "Request rejected";
    }
    return isArabic ? "اطلب الانضمام" : "Request access";
  }


  Color? get _statusColor {
    switch (widget.enrollmentStatus) {
      case 'pending': return AppColors.warning;
      case 'approved': return AppColors.success;
      case 'rejected': return AppColors.danger;
      default: return null;
    }
  }

  String _statusLabel(bool isArabic) {
    switch (widget.enrollmentStatus) {
      case 'pending': return isArabic ? 'الطلب قيد المراجعة' : 'Pending review';
      case 'approved': return isArabic ? 'تم قبول الطلب' : 'Approved';
      case 'rejected': return isArabic ? 'تم رفض الطلب' : 'Rejected';
      default: return '';
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
        // Request cards change height when a status chip appears. Keeping
        // their height intrinsic prevents the 14px overflow after requesting.
        height: widget.height ??
            (widget.isEnrolled ? getScreenHeight(context) * 0.28 : null),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: _statusColor == null ? null : Border.all(color: _statusColor!.withOpacity(.55)),
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
                          height: getScreenHeight(context) * 0.17500,
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
                              size: getScreenWidth(context) * 0.05128,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(getScreenWidth(context) * 0.03077),
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
                  SizedBox(height: getScreenHeight(context) * 0.00500),
                  defaultText(
                    context: context,
                    text: widget.author,
                    size: getScreenWidth(context) * 0.033,
                    color: Colors.white70,
                    isCenter: false,
                  ),

                  ratingWidget(value: widget.rating, context: context),
                  if (widget.enrollmentStatus != null && widget.isEnrolled == false) ...[
                    SizedBox(height: getScreenHeight(context) * 0.008),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _statusColor?.withOpacity(.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _statusLabel(isArabic),
                        style: TextStyle(color: _statusColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                  SizedBox(height: getScreenHeight(context) * 0.01250),
                  if (widget.isEnrolled == false)
                    FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slide,
                        child: CustomGlowButton(
                          width: double.infinity,
                          textSize: getScreenWidth(context) * 0.035,
                          title: _enrollButtonTitle(isArabic),
                          onPressed: _canPressEnroll
                              ? () => _handleEnroll(isArabic)
                              : null,
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
