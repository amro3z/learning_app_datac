import 'package:flutter/material.dart';
import 'package:training/helper/base.dart';
import 'package:training/helper/custom_glow_buttom.dart';
import 'package:training/widgets/instrauctor_card.dart';
import 'package:training/widgets/lesson_card.dart';

class CourseDetails extends StatefulWidget {
 const CourseDetails({
    super.key,
    required this.imageURL,
    required this.title,
    required this.instructor,
    required this.description,
    required this.progress,
    required this.onFavoriteToggle,
    required this.isFavorite,
    required this.courseId,
  });
  final String imageURL;
  final String title;
  final String instructor;
  final String description;
  final double progress;
  final bool isFavorite;
  final int courseId;
  
  final Function() onFavoriteToggle;

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: defaultText(text: "Course Details", size: 18, isCenter: false),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isFavorite = !_isFavorite;
                widget.onFavoriteToggle();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: widget.isFavorite ? Colors.red : Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  Container(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            defaultText(
                              text: "Course Progress",
                              size: 14,
                              isCenter: false,
                            ),
                            const SizedBox(width: 10),
                            defaultText(
                              text:
                                  "${(widget.progress * 100).toStringAsFixed(0)}%",
                              size: 14,
                              isCenter: false,
                              color: Colors.lightBlue,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        progressBar(progress: widget.progress, height: 13),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Lessons(courseId: widget.courseId,),
                  SizedBox(height: 15),
                  CustomGlowButton(
                    title: "Continue Learning",
                    onPressed: () {},
                    width: double.infinity,
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
