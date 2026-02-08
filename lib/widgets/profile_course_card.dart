import 'package:flutter/material.dart';
import 'package:training/helper/base.dart';

class ProfileCourseCard extends StatelessWidget {
  const ProfileCourseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(8),
      ),

      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/pro2.jpeg',
                  height: 60,
                  width: 60,
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
                    text: '20% completed',
                    size: 12,
                    color: Colors.grey,
                    bold: false,
                    isCenter: false,
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 30),
            ],
          ),
          const SizedBox(height: 12),
          progressBar(progress: 0.8),
        ],
      ),
    );
  }
}
