import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:training/cubits/cubit/enrollments_cubit.dart';
import 'package:training/cubits/cubit/lessons_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/helper/base.dart';
import 'package:training/widgets/instrauctor_card.dart';
import 'package:training/widgets/lesson_card.dart';

class CourseDetails extends StatefulWidget {
  const CourseDetails({
    super.key,
    required this.imageURL,
    required this.title,
    required this.instructor,
    required this.description,
    required this.courseId,
  });

  final String imageURL;
  final String title;
  final String instructor;
  final String description;
  final int courseId;

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails> {


  @override
  void initState() {
    super.initState();
  }

Future<void> _refreshData() async {
    final userId = context.read<UserCubit>().userId;
    if (userId == null) return;

    await context.read<LessonsCubit>().getLessons();

    await context.read<EnrollmentsCubit>().getAllEnrollments(userId: userId);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: defaultText(text: "Course Details", size: 18, isCenter: false),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        color: Colors.blue,
        backgroundColor: Colors.white,
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// صورة الكورس
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 260,
                    child: Image.network(widget.imageURL, fit: BoxFit.cover),
                  ),
                  Container(
                    height: 260,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.85),
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    defaultText(text: widget.title, size: 18, isCenter: false),
                    const SizedBox(height: 8),

                    instructorCard(instructor: widget.instructor),
                    const SizedBox(height: 8),

                    defaultText(
                      align: TextAlign.start,
                      text: widget.description,
                      size: 14,
                      isCenter: false,
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 12),

                    /// =========================
                    /// Course Progress
                    /// =========================
                    BlocBuilder<EnrollmentsCubit, EnrollmentsState>(
                      builder: (context, state) {
                        double progress = 0;

                        if (state is EnrollmentsLoaded) {
                          final enrollment = state.enrollments.firstWhereOrNull(
                            (e) => e.courseId == widget.courseId,
                          );

                          if (enrollment != null) {
                            progress = enrollment.progressPercent;

                            // لو السيرفر بيرجع 100 بدل 1
                            if (progress > 1) {
                              progress = progress / 100;
                            }

                            // حماية من أي قيمة غلط
                            progress = progress.clamp(0.0, 1.0);
                          }
                        }

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            border: Border.all(color: Colors.white12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  defaultText(
                                    text: "Course Progress",
                                    size: 14,
                                    isCenter: false,
                                  ),
                                  defaultText(
                                    text:
                                        "${(progress * 100).toStringAsFixed(0)}%",
                                    size: 14,
                                    isCenter: false,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              progressBar(progress: progress, height: 13),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    /// Lessons
                    Lessons(
                      courseId: widget.courseId,
                      courseTitle: widget.title,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
