import 'package:flutter/material.dart';
import 'package:training/helper/base.dart';
import 'package:training/services/video_player.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.videoURl,
    required this.lessonTitle,
    required this.lessonDescription,
    required this.lessonID,
    required this.courseID,
    required this.courseTitle,
    required this.lessonDurationInSeconds,
  });
  final String videoURl;
  final String lessonTitle;
  final String lessonDescription;
  final int lessonID;
  final int courseID;
  final String courseTitle;
  final int lessonDurationInSeconds ;
  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: defaultText(text: widget.courseTitle, size: 20),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
          top: 24,
          bottom: 90,
        ),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 200,
              child: YoutubePlayerWidget(
                courseId: widget.courseID,
                lessonId: widget.lessonID,
                lessonDurationInSeconds: widget.lessonDurationInSeconds,
                youtubeUrl: widget.videoURl,
              ),
            ),
            SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                border: Border.all(color: Colors.white12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  defaultText(text: widget.lessonTitle, size: 16),
                  SizedBox(height: 5),
                  defaultText(
                    text: widget.lessonDescription,
                    size: 14,
                    color: Colors.grey,
                    align: TextAlign.start,
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
