import 'package:flutter/material.dart';
import 'package:training/helper/base.dart';
import 'package:training/helper/custom_glow_buttom.dart';

class CourseDetails extends StatefulWidget {
  const CourseDetails({super.key});

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails> {
  bool isFavorite = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: defaultText(text: "Course Details", size: 18, isCenter: false),
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.white,
                size: 22,
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
                  child: Image.asset(
                    'assets/images/draft.jpeg',
                    fit: BoxFit.cover,
                  ),
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
                  defaultText(
                    text: "Complete Web Development Bootcamp",
                    size: 18,
                    isCenter: false,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/draft.jpeg',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          defaultText(
                            text: "Instructor",
                            size: 12,
                            isCenter: false,
                            color: Colors.grey,
                          ),
                          defaultText(
                            text: "John Doe",
                            size: 14,
                            isCenter: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  defaultText(
                    align: TextAlign.start,
                    text:
                        "Learn web development from scratch with HTML, CSS, JavaScript, React, Node.js and more. Build real-world projects and become a full-stack developer.",
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
                              text: "45%",
                              size: 14,
                              isCenter: false,
                              color: Colors.lightBlue,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        progressBar(progress: 0.45, height: 13),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  defaultText(text: 'Lessons (10)', size: 18),
                  const SizedBox(height: 8),
                  lessonCard(
                    duration: "45:30",
                    state: CourseStatus.completed,
                    title: "Introduction to Web Development",
                  ),
                  SizedBox(height: 8),
                  lessonCard(
                    duration: "45:30",
                    state: CourseStatus.inProgress,
                    title: "Introduction to Web Development",
                  ),
                  SizedBox(height: 8),
                  lessonCard(
                    duration: "45:30",
                    state: CourseStatus.locked,
                    title: "Introduction to Web Development",
                  ),
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
