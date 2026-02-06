import 'package:flutter/material.dart';
import 'package:training/helper/base.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String author;
  final double rating;
  final double progress;
  final String imagePath;

  const CourseCard({
    super.key,
    required this.title,
    required this.author,
    required this.rating,
    required this.progress,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/course_details');
      },
      child: Container(
        height: 265,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                imagePath,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  defaultText(
                    text: title,
                    size: 16,
                    color: Colors.white,
                    bold: true,
                    isCenter: false,
                  ),
                  const SizedBox(height: 4),

                  // Author
                  defaultText(
                    text: author,
                    size: 13,
                    color: Colors.white.withOpacity(0.6),
                    bold: false,
                    isCenter: false,
                  ),
                  const SizedBox(height: 8),

                  // Rating
                  ratingWidget(value: rating),
                  const SizedBox(height: 10),

                  // Progress bar
                  progressBar(progress: progress),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}
