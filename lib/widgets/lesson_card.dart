import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/helper/base.dart';

enum CourseStatus { completed, present, locked }

const Map<CourseStatus, IconData> _icons = {
  CourseStatus.completed: Icons.check_circle,
  CourseStatus.present: Icons.play_circle_fill,
  CourseStatus.locked: Icons.radio_button_unchecked,
};

const Map<CourseStatus, Color> _colors = {
  CourseStatus.completed: Colors.green,
  CourseStatus.present: Colors.lightBlue,
  CourseStatus.locked: Colors.grey,
};

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.titleEn,
    required this.titleAr,
    required this.duration,
    required this.state,
    required this.courseID,
    required this.lessonID,
    required this.lessonDurationInSeconds,
    required this.lessonDescriptionEn,
    required this.lessonDescriptionAr,
    required this.videoURl,
    required this.courseTitle,
  });

  final String titleEn;
  final String titleAr;
  final int duration;
  final CourseStatus state;
  final int courseID;
  final int lessonID;
  final int lessonDurationInSeconds;
  final String lessonDescriptionEn;
  final String lessonDescriptionAr;
  final String videoURl;
  final String courseTitle;

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final languageCode = langState is LanguageCubitLoaded
        ? langState.languageCode
        : 'en';

    final title = languageCode == 'ar' ? titleAr : titleEn;

    final description = languageCode == 'ar'
        ? lessonDescriptionAr
        : lessonDescriptionEn;

    return GestureDetector(
      onTap: state == CourseStatus.locked
          ? null
          : () {
              Navigator.pushNamed(
                context,
                '/lesson_screen',
                arguments: {
                  'courseID': courseID,
                  'lessonID': lessonID,
                  'lessonTitle': title,
                  'lessonDescription': description,
                  'videoURl': videoURl,
                  'courseTitle': courseTitle,
                  'lessonDurationInSeconds': lessonDurationInSeconds,
                },
              );
            },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          border: Border.all(color: Colors.white12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              _icons[state]!,
              color: _colors[state],
              size: getScreenWidth(context) * 0.08,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  defaultText(
                    text: title,
                    size: getScreenWidth(context) * 0.035,
                    isCenter: false,
                    context: context,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_sharp,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      defaultText(
                        context: context,
                        text: languageCode == 'ar'
                            ? "$duration دقيقة"
                            : "$duration min",
                        size: getScreenWidth(context) * 0.035,
                        isCenter: false,
                        color: Colors.grey,
                      ),
                    ],
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
