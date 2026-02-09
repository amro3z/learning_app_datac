import 'package:flutter/material.dart';
import 'package:training/helper/base.dart';
import 'package:training/helper/custom_glow_buttom.dart';

class RecommendedCard extends StatelessWidget {
  const RecommendedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/pro2.jpeg',
              height: 110,
              width: 110,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              defaultText(
                text: 'Flutter for Beginners',
                size: 14,
                color: Colors.white,
                bold: true,
                isCenter: false,
              ),
              const SizedBox(height: 4),
              defaultText(
                text: 'John Doe',
                size: 12,
                color: Colors.white.withOpacity(0.6),
                bold: false,
                isCenter: false,
              ),
              const SizedBox(height: 8),
              defaultText(text: "⭐ 4.5", size: 12),
              const SizedBox(height: 8),
              CustomGlowButton(
                title: 'Enroll Now',
                onPressed: () {
                  Navigator.pushNamed(context, '/course_details');
                },
                textSize: 12,
                width: 80,
              ),
            ],
          ),
        ],
      ),
    );
  }
}


