import 'package:flutter/material.dart';
import 'package:training/helper/base.dart';
import 'package:training/services/video_player.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: defaultText(text: "JavaScript Basics", size: 20),
        leading: Icon(Icons.arrow_back_ios, size: 24),
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
                youtubeUrl: 'https://youtu.be/hyQtg-yMlOs?si=pMOm-P_Zyc7GmgGJ',
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
                  defaultText(
                    text: "Lesson 4: JavaScript Essentials",
                    size: 16,
                  ),
                  SizedBox(height: 5),
                  defaultText(
                    text:
                        "Learn the basics of JavaScript, including variables, functions, and control structures. la kjdskfjklhsdfjlhjlsdhfljhjklsdfhjlhsdjkfhkjdshfljdshfljhsldjfhljdhfljhdsfljhdsjl",
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
