import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/data/api/api_constant.dart';
import 'package:training/helper/base.dart';
import 'package:training/helper/custom_glow_buttom.dart';
import 'package:training/screen/pdf_screen.dart';
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
    this.pdf,
  });

  final String videoURl;
  final String lessonTitle;
  final String lessonDescription;
  final int lessonID;
  final int courseID;
  final String courseTitle;
  final int lessonDurationInSeconds;
  final String? pdf;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final isArabic =
        langState is LanguageCubitLoaded && langState.languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(
        title: defaultText(
          text: widget.courseTitle,
          size: getScreenWidth(context) * 0.045,
          context: context,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: getScreenWidth(context) * 0.07,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
     body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(12, 24, 12, 24),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayerWidget(
                  courseId: widget.courseID,
                  lessonId: widget.lessonID,
                  lessonDurationInSeconds: widget.lessonDurationInSeconds,
                  youtubeUrl: widget.videoURl,
                ),
              ),

              SizedBox(height: getScreenHeight(context) * 0.02500),

              Container(
                padding: EdgeInsets.all(getScreenWidth(context) * 0.03077),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  border: Border.all(color: Colors.white12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    defaultText(
                      text: widget.lessonTitle,
                      size: getScreenWidth(context) * 0.04,
                      context: context,
                    ),
                    SizedBox(height: getScreenHeight(context) * 0.00625),
                    defaultText(
                      context: context,
                      text: widget.lessonDescription,
                      size: getScreenWidth(context) * 0.035,
                      color: Colors.grey,
                      align: TextAlign.start,
                    ),
                  ],
                ),
              ),

              SizedBox(height: getScreenHeight(context) * 0.02500),

              CustomGlowButton(
                title: isArabic ? "عرض PDF" : "View PDF",
                onPressed: widget.pdf != null && widget.pdf!.isNotEmpty
                    ? () {
                        final url = "$baseUrl/assets/${widget.pdf}";
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PdfScreen(url: url),
                          ),
                        );
                      }
                    : null,
                width: getScreenWidth(context) * 0.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
