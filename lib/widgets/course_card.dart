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
    return Container(
      height: 280,
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => Icon(
                        index < rating.floor() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      rating.toString(),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF7B61FF)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
