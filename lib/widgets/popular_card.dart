import 'package:flutter/material.dart';
import 'package:training/helper/base.dart';

class PopularCard extends StatelessWidget {
  const PopularCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/pro2.jpeg',
            height: 100,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                defaultText(
                  text: 'Flutter for Beginners',
                  size: 16,
                  color: Colors.white,
                  bold: true,
                  isCenter: false,
                ),
                defaultText(text: "⭐ 4.5", size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
